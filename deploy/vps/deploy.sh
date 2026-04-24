#!/usr/bin/env bash
# deploy.sh <IMAGE> <ENV>
#
# Executado pelo receiver quando o webhook chega.
# Ordem: pull → migrate → compose up → health check → rollback se falhar
#
# Variáveis lidas do ambiente:
#   COMPOSE_BASE   diretório base das stacks (default: /opt/maestro)
#   HEALTH_PATH    path do endpoint de health (default: /health)
#   HEALTH_PORT    porta interna do app (default: 8080)
#   HEALTH_RETRIES quantas tentativas antes de desistir (default: 18 = 90s)
#   HEALTH_WAIT    segundos entre tentativas (default: 5)

set -euo pipefail

IMAGE="${1:?Uso: deploy.sh <image> <env>}"
ENV="${2:?Uso: deploy.sh <image> <env>}"

COMPOSE_BASE="${COMPOSE_BASE:-/opt/maestro}"
COMPOSE_FILE="$COMPOSE_BASE/$ENV/docker-compose.yml"
ENV_FILE="$COMPOSE_BASE/$ENV/.env"
HEALTH_PATH="${HEALTH_PATH:-/health}"
HEALTH_PORT="${HEALTH_PORT:-8080}"
HEALTH_RETRIES="${HEALTH_RETRIES:-18}"
HEALTH_WAIT="${HEALTH_WAIT:-5}"
ROLLBACK_SCRIPT="$(dirname "$0")/rollback.sh"

log() { printf '[%s] %s\n' "$(date -u +%FT%TZ)" "$*"; }
die() { log "ERRO: $*"; exit 1; }

[[ -f "$COMPOSE_FILE" ]] || die "Compose file não encontrado: $COMPOSE_FILE"
[[ -f "$ENV_FILE"     ]] || die ".env não encontrado: $ENV_FILE"

# ── 0. Registrar imagem anterior para rollback ───────────────────────────────
PREV_IMAGE=$(docker compose -f "$COMPOSE_FILE" \
  --env-file "$ENV_FILE" \
  images --format json 2>/dev/null \
  | jq -r '.[0].Image // empty' || true)

log "Imagem anterior: ${PREV_IMAGE:-<nenhuma>}"
log "Nova imagem:     $IMAGE"
log "Ambiente:        $ENV"

# ── 1. Pull ──────────────────────────────────────────────────────────────────
log "1/5 Pulling $IMAGE"
docker pull "$IMAGE" || die "Pull falhou"

# ── 2. Verificar assinatura cosign ──────────────────────────────────────────
if command -v cosign &>/dev/null; then
  log "2/5 Verificando assinatura cosign"
  cosign verify \
    --certificate-identity-regexp "https://github.com/devchave/.*" \
    --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
    "$IMAGE" || die "Verificação cosign falhou — deploy cancelado"
else
  log "2/5 cosign não instalado — pulando verificação (instale em produção)"
fi

# ── 3. Migrações ─────────────────────────────────────────────────────────────
log "3/5 Rodando migrações"
docker run --rm \
  --env-file "$ENV_FILE" \
  --network "maestro_${ENV}_net" \
  "$IMAGE" node dist/migrate.js \
|| die "Migração falhou — abortando deploy (banco não foi alterado pela app)"

# ── 4. Compose up ────────────────────────────────────────────────────────────
log "4/5 Subindo containers"
IMAGE="$IMAGE" docker compose \
  -f "$COMPOSE_FILE" \
  --env-file "$ENV_FILE" \
  up -d --remove-orphans \
|| die "docker compose up falhou"

# ── 5. Health check ──────────────────────────────────────────────────────────
log "5/5 Health check (até $((HEALTH_RETRIES * HEALTH_WAIT))s)"

for i in $(seq 1 "$HEALTH_RETRIES"); do
  HTTP=$(curl -sf -o /dev/null -w "%{http_code}" \
    "http://127.0.0.1:${HEALTH_PORT}${HEALTH_PATH}" 2>/dev/null || echo 000)

  if [[ "$HTTP" == "200" ]]; then
    log "✅ Health OK (tentativa $i) — deploy concluído"
    exit 0
  fi

  log "  Tentativa $i/$HEALTH_RETRIES — HTTP $HTTP — aguardando ${HEALTH_WAIT}s"
  sleep "$HEALTH_WAIT"
done

# ── Rollback automático ──────────────────────────────────────────────────────
log "❌ Health check esgotado — iniciando rollback"
bash "$ROLLBACK_SCRIPT" "$COMPOSE_FILE" "$ENV_FILE" "$PREV_IMAGE"
exit 1
