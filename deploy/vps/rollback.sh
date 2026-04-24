#!/usr/bin/env bash
# rollback.sh <compose-file> <env-file> [imagem-anterior]
#
# Chamado automaticamente pelo deploy.sh em falha de health.
# Pode também ser chamado manualmente para rollback ad-hoc.

set -euo pipefail

COMPOSE_FILE="${1:?compose file obrigatório}"
ENV_FILE="${2:?env file obrigatório}"
PREV_IMAGE="${3:-}"

log() { printf '[%s] ROLLBACK: %s\n' "$(date -u +%FT%TZ)" "$*"; }

log "Iniciando rollback — compose: $COMPOSE_FILE"

if [[ -n "$PREV_IMAGE" ]]; then
  log "Revertendo para $PREV_IMAGE"
  docker pull "$PREV_IMAGE" 2>/dev/null || log "Pull da imagem anterior falhou — tentando com o que está em cache"
  IMAGE="$PREV_IMAGE" docker compose \
    -f "$COMPOSE_FILE" \
    --env-file "$ENV_FILE" \
    up -d --remove-orphans
  log "Rollback para $PREV_IMAGE concluído — verifique manualmente"
else
  log "Nenhuma imagem anterior registrada — derrubando containers para evitar estado corrompido"
  docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" down
  log "Containers derrubados — intervenção manual necessária"
fi
