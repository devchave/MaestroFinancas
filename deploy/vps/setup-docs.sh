#!/usr/bin/env bash
# setup-docs.sh
#
# Adiciona o site de documentação à VPS que já passou pelo setup-vps.sh.
# Uso: sudo bash setup-docs.sh <dominio-dos-docs>
# Ex:  sudo bash setup-docs.sh docs.maestrofinancas.com.br
#
# Pré-requisitos: setup-vps.sh já executado (nginx, Docker, usuário deploy).

set -euo pipefail
log() { printf '\n\033[1;34m▶ %s\033[0m\n' "$*"; }
ok()  { printf '\033[1;32m  ✔ %s\033[0m\n' "$*"; }

DOCS_DOMAIN="${1:?Uso: setup-docs.sh <dominio>  ex: docs.maestrofinancas.com.br}"

# ── 1. Diretório da stack de docs ────────────────────────────────────────────
log "Criando /opt/maestro/docs"
install -d -m 750 -o deploy -g deploy /opt/maestro/docs

# ── 2. docker-compose para o serviço de docs ─────────────────────────────────
log "Criando docker-compose.docs.yml em /opt/maestro/docs/"
cat > /opt/maestro/docs/docker-compose.yml << 'COMPOSEEOF'
services:
  docs:
    image: ghcr.io/devchave/maestrofinan-as-docs:${DOCS_TAG:-latest}
    container_name: maestro_docs
    restart: unless-stopped
    ports:
      - "127.0.0.1:8001:80"
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost/health"]
      interval: 30s
      timeout: 5s
      retries: 3
COMPOSEEOF

cat > /opt/maestro/docs/.env << ENVEOF
DOCS_TAG=latest
ENVEOF

chown deploy:deploy /opt/maestro/docs/docker-compose.yml /opt/maestro/docs/.env
ok "docker-compose criado"

# ── 3. nginx vhost para docs ─────────────────────────────────────────────────
log "Configurando nginx para $DOCS_DOMAIN"
cat > /etc/nginx/sites-available/maestro-docs << NGINXEOF
server {
    listen 80;
    server_name $DOCS_DOMAIN;
    location /.well-known/acme-challenge/ { root /var/www/html; }
    location / { return 301 https://\$host\$request_uri; }
}

server {
    listen 443 ssl http2;
    server_name $DOCS_DOMAIN;

    ssl_certificate     /etc/letsencrypt/live/$DOCS_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOCS_DOMAIN/privkey.pem;
    ssl_protocols TLSv1.3;

    location / {
        proxy_pass         http://127.0.0.1:8001;
        proxy_set_header   Host \$host;
        proxy_cache_bypass \$http_pragma;
        add_header         X-Cache-Status \$upstream_cache_status;
    }
}
NGINXEOF

ln -sf /etc/nginx/sites-available/maestro-docs \
        /etc/nginx/sites-enabled/maestro-docs
nginx -t && systemctl reload nginx
ok "nginx configurado para $DOCS_DOMAIN"

# ── 4. TLS ───────────────────────────────────────────────────────────────────
log "Obtendo certificado TLS para $DOCS_DOMAIN"
certbot --nginx -d "$DOCS_DOMAIN" --non-interactive --agree-tos \
  --email "desenvolvimento@chavemestresolucoes.com.br" \
|| log "  ⚠️  certbot falhou — certifique-se de que o DNS $DOCS_DOMAIN aponta para este IP"
ok "TLS configurado"

# ── 5. Primeiro pull manual da imagem ────────────────────────────────────────
log "Fazendo login no GHCR (precisa de token GitHub)"
echo "  Para completar: docker login ghcr.io -u devchave --password <SEU_TOKEN_GITHUB>"
echo "  Depois:         cd /opt/maestro/docs && docker compose up -d"

printf '\n\033[1;32m══════════════════════════════════════════════════\033[0m\n'
printf '\033[1;32m  Docs estarão em: https://%s\033[0m\n' "$DOCS_DOMAIN"
printf '\033[1;32m══════════════════════════════════════════════════\033[0m\n'
