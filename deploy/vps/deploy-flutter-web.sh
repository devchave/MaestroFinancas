#!/bin/bash
# Roda no VPS para fazer o primeiro deploy do Flutter Web
# Usage: bash deploy-flutter-web.sh

set -e

REPO="https://github.com/devchave/MaestroFinancas.git"
APP_DIR="/srv/maestro/app/web"
NGINX_CONF="/etc/nginx/sites-available/maestro"

echo "==> Clonando repositório..."
rm -rf /tmp/maestro-deploy
git clone --depth 1 --branch main "$REPO" /tmp/maestro-deploy

echo "==> Copiando arquivos Flutter web..."
mkdir -p "$APP_DIR"
cp -r /tmp/maestro-deploy/dist/web/. "$APP_DIR/"
rm -rf /tmp/maestro-deploy

echo "==> Configurando nginx..."
cat > "$NGINX_CONF" << 'EOF'
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

    root /srv/maestro/app/web;
    index index.html;

    # Flutter web — redireciona qualquer rota para index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache para assets estáticos
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2|ttf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/maestro 2>/dev/null || true
nginx -t && systemctl reload nginx

echo ""
echo "✅ Deploy concluído!"
echo "   Acesse: https://maestrofinancas.chavemestresolucoes.com"
