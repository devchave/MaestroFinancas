#!/usr/bin/env bash
# setup-vps.sh
#
# Executar UMA vez na VPS limpa (Ubuntu 22.04 / Debian 12).
# Configura: Docker, usuário deploy, diretórios, systemd, nginx (proxy reverso).
#
# Uso: sudo bash setup-vps.sh
# Pré-requisitos: rodar como root ou com sudo.

set -euo pipefail
log() { printf '\n\033[1;34m▶ %s\033[0m\n' "$*"; }
ok()  { printf '\033[1;32m  ✔ %s\033[0m\n' "$*"; }

# ── 1. Docker ────────────────────────────────────────────────────────────────
log "Instalando Docker"
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sh
fi
systemctl enable --now docker
ok "Docker $(docker --version)"

# ── 2. cosign ────────────────────────────────────────────────────────────────
log "Instalando cosign"
COSIGN_VER="v2.2.4"
curl -sSL "https://github.com/sigstore/cosign/releases/download/${COSIGN_VER}/cosign-linux-amd64" \
  -o /usr/local/bin/cosign
chmod +x /usr/local/bin/cosign
ok "cosign $(cosign version 2>&1 | head -1)"

# ── 3. Usuário deploy ────────────────────────────────────────────────────────
log "Criando usuário 'deploy'"
if ! id deploy &>/dev/null; then
  useradd --system --shell /bin/bash --create-home deploy
fi
usermod -aG docker deploy
ok "Usuário deploy criado e adicionado ao grupo docker"

# ── 4. Node.js (receiver) ────────────────────────────────────────────────────
log "Instalando Node.js 22 LTS"
if ! command -v node &>/dev/null || [[ "$(node -e 'process.exit(+process.version.slice(1).split(".")[0] < 22)')" ]]; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  apt-get install -y nodejs
fi
ok "Node $(node --version)"

# ── 5. Diretórios ────────────────────────────────────────────────────────────
log "Criando diretórios"
install -d -m 750 -o deploy -g deploy \
  /opt/maestro/receiver \
  /opt/maestro/staging \
  /opt/maestro/production \
  /var/log/maestro
ok "Diretórios criados"

# ── 6. Arquivo de segredos do receiver ───────────────────────────────────────
log "Criando /etc/maestro/receiver.env (preencher manualmente)"
install -d -m 700 /etc/maestro
cat > /etc/maestro/receiver.env << 'ENVEOF'
# Preencha os valores reais e proteja o arquivo (chmod 600)
WEBHOOK_SECRET=<SUBSTITUA_PELO_SEGREDO_DO_GITHUB>
DEPLOY_SCRIPT=/opt/maestro/deploy.sh
LOG_FILE=/var/log/maestro/deploys.jsonl
# Opcional — webhook do Discord para notificações
DISCORD_WEBHOOK_URL=
PORT=9000
ENVEOF
chmod 600 /etc/maestro/receiver.env
chown root:deploy /etc/maestro/receiver.env
ok "receiver.env criado em /etc/maestro/ — PREENCHA o WEBHOOK_SECRET"

# ── 7. Copiar scripts ────────────────────────────────────────────────────────
log "Copiando scripts de deploy"
# Pressupõe que o repo está clonado em /opt/maestro/repo
REPO_DIR="${REPO_DIR:-/opt/maestro/repo}"
if [[ -d "$REPO_DIR/deploy/vps" ]]; then
  cp "$REPO_DIR/deploy/vps/deploy.sh"   /opt/maestro/deploy.sh
  cp "$REPO_DIR/deploy/vps/rollback.sh" /opt/maestro/rollback.sh
  chmod +x /opt/maestro/deploy.sh /opt/maestro/rollback.sh
  chown deploy:deploy /opt/maestro/deploy.sh /opt/maestro/rollback.sh

  cp -r "$REPO_DIR/deploy/vps/receiver/." /opt/maestro/receiver/
  cd /opt/maestro/receiver && npm install --omit=dev
  chown -R deploy:deploy /opt/maestro/receiver
  ok "Scripts copiados"
else
  log "  ⚠️  $REPO_DIR não existe — copie manualmente os scripts de deploy/vps/"
fi

# ── 8. Systemd ───────────────────────────────────────────────────────────────
log "Registrando serviço systemd"
if [[ -f "$REPO_DIR/deploy/vps/maestro-deploy.service" ]]; then
  cp "$REPO_DIR/deploy/vps/maestro-deploy.service" \
     /etc/systemd/system/maestro-deploy.service
  systemctl daemon-reload
  systemctl enable maestro-deploy
  ok "maestro-deploy.service registrado (não iniciado — preencha receiver.env primeiro)"
fi

# ── 9. nginx (proxy reverso TLS) ─────────────────────────────────────────────
log "Configurando nginx"
apt-get install -y nginx certbot python3-certbot-nginx

DOMAIN="${VPS_DOMAIN:-maestrofinancas.chavemestresolucoes.com}"
cat > /etc/nginx/sites-available/maestro-deploy << NGINXEOF
server {
    listen 80;
    server_name $DOMAIN;

    location /.well-known/acme-challenge/ { root /var/www/html; }
    location / { return 301 https://\$host\$request_uri; }
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate     /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.3;
    ssl_prefer_server_ciphers on;

    # Apenas as rotas do receiver ficam expostas
    location ~ ^/(deploy|health|status)$ {
        proxy_pass http://127.0.0.1:9000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_read_timeout 30s;
    }

    # Bloqueia todo o resto
    location / { return 404; }
}
NGINXEOF
ln -sf /etc/nginx/sites-available/maestro-deploy \
        /etc/nginx/sites-enabled/maestro-deploy
nginx -t && systemctl reload nginx
ok "nginx configurado — obtenha TLS com: certbot --nginx -d $DOMAIN"

# ── 10. Firewall básico ──────────────────────────────────────────────────────
log "Configurando UFW"
apt-get install -y ufw
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP (redirect)
ufw allow 443/tcp   # HTTPS (receiver via nginx)
ufw --force enable
ok "UFW ativo (22, 80, 443)"

printf '\n\033[1;33m══════════════════════════════════════════════\033[0m\n'
printf '\033[1;33m  Próximos passos manuais:\033[0m\n'
printf '  1. Preencher /etc/maestro/receiver.env\n'
printf '  2. Obter TLS: certbot --nginx -d maestrofinancas.chavemestresolucoes.com\n'
printf '  3. Criar /opt/maestro/staging/.env e /opt/maestro/production/.env\n'
printf '  4. Criar /opt/maestro/staging/docker-compose.yml (e production/)\n'
printf '  5. Iniciar o receiver: systemctl start maestro-deploy\n'
printf '  6. Adicionar secrets no GitHub (ver doc 08-cicd-deploy.md)\n'
printf '\033[1;33m══════════════════════════════════════════════\033[0m\n'
