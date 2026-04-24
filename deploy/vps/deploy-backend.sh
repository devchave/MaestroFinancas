#!/bin/bash
# Deploy do backend Maestro Finanças no VPS
# Roda como root no VPS: bash deploy-backend.sh
set -e

REPO="https://github.com/devchave/MaestroFinancas.git"
APP_DIR="/srv/maestro"
NGINX_CONF="/etc/nginx/sites-available/maestro"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Maestro Finanças — Backend Deploy   ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── 1. Clonar/atualizar repositório ──────────────────────────────────────────
echo "==> [1/5] Atualizando repositório..."
if [ -d "$APP_DIR/.git" ]; then
  git -C "$APP_DIR" pull origin main
else
  git clone --depth 1 --branch main "$REPO" "$APP_DIR"
fi

# ── 2. Copiar build Flutter web ───────────────────────────────────────────────
echo "==> [2/5] Implantando Flutter web..."
mkdir -p "$APP_DIR/app/web"
cp -r "$APP_DIR/dist/web/." "$APP_DIR/app/web/"

# ── 3. Subir PostgreSQL + API ────────────────────────────────────────────────
echo "==> [3/5] Iniciando banco de dados e API..."
cd "$APP_DIR"
docker compose up -d --build
echo "    Aguardando API iniciar (pode levar ~30s na primeira vez)..."
for i in $(seq 1 30); do
  sleep 2
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/health 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ]; then
    echo "    ✅ API respondendo!"
    break
  fi
  echo "    ... tentativa $i/30 (status: $STATUS)"
done

# ── 4. Configurar nginx ───────────────────────────────────────────────────────
echo "==> [4/5] Configurando nginx..."
cat > "$NGINX_CONF" << 'NGINX'
server {
    listen 80;
    server_name maestrofinancas.chavemestresolucoes.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name maestrofinancas.chavemestresolucoes.com;

    ssl_certificate     /etc/letsencrypt/live/maestrofinancas.chavemestresolucoes.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/maestrofinancas.chavemestresolucoes.com/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;

    # ── API Backend ──
    location /api/ {
        proxy_pass         http://127.0.0.1:8000/api/;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }

    # ── Flutter Web App ──
    root  /srv/maestro/app/web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2|ttf|wasm)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
NGINX

ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/maestro 2>/dev/null || true
nginx -t && systemctl reload nginx

# ── 5. Verificar usuário de teste ────────────────────────────────────────────
echo "==> [5/5] Verificando login de teste..."
sleep 2
RESULT=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"teste@maestro.com","password":"Maestro@2025"}' \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('OK' if 'access_token' in d else d)" 2>/dev/null || echo "FALHOU")

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║           ✅  Deploy Concluído!               ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  Site:    https://maestrofinancas.chavemestresolucoes.com"
echo "║  API:     https://maestrofinancas.chavemestresolucoes.com/api/health"
echo "╠══════════════════════════════════════════════╣"
echo "║  Login de teste:                             ║"
echo "║    Email:  teste@maestro.com                 ║"
echo "║    Senha:  Maestro@2025                      ║"
echo "║  Teste auth: $RESULT"
echo "╚══════════════════════════════════════════════╝"
echo ""
