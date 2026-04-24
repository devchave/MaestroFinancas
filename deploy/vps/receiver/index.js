/**
 * MaestroFinanças — Deploy Webhook Receiver
 *
 * Roda na VPS atrás de nginx (apenas 127.0.0.1:9000, não exposto diretamente).
 * Nginx faz proxy reverso com TLS e limita a rota /deploy ao IP do GitHub Actions.
 *
 * Variáveis de ambiente (ver /etc/maestro/receiver.env):
 *   WEBHOOK_SECRET       segredo compartilhado com o GitHub Actions
 *   DEPLOY_SCRIPT        caminho do deploy.sh (default: /opt/maestro/deploy.sh)
 *   LOG_FILE             (default: /var/log/maestro/deploys.jsonl)
 *   DISCORD_WEBHOOK_URL  (opcional) URL do webhook do Discord
 *   PORT                 (default: 9000)
 */

import http from 'node:http';
import crypto from 'node:crypto';
import { execFile } from 'node:child_process';
import { appendFileSync, mkdirSync } from 'node:fs';
import { dirname } from 'node:path';

const PORT          = parseInt(process.env.PORT          ?? '9000');
const SECRET        = process.env.WEBHOOK_SECRET;
const DEPLOY_SCRIPT = process.env.DEPLOY_SCRIPT          ?? '/opt/maestro/deploy.sh';
const LOG_FILE      = process.env.LOG_FILE               ?? '/var/log/maestro/deploys.jsonl';
const DISCORD_URL   = process.env.DISCORD_WEBHOOK_URL;
const RATE_LIMIT_MS = 60_000;   // 1 deploy por minuto no mínimo

if (!SECRET) { console.error('WEBHOOK_SECRET não definido'); process.exit(1); }
mkdirSync(dirname(LOG_FILE), { recursive: true });

let deploying    = false;
let lastDeployAt = 0;

// ── Utilitários ─────────────────────────────────────────────────────────────

function log(entry) {
  const line = JSON.stringify({ ts: new Date().toISOString(), ...entry });
  appendFileSync(LOG_FILE, line + '\n');
  console.log(line);
}

function verifyHmac(body, signature) {
  const expected = 'sha256=' + crypto
    .createHmac('sha256', SECRET)
    .update(body)
    .digest('hex');
  try {
    return crypto.timingSafeEqual(Buffer.from(expected), Buffer.from(signature ?? ''));
  } catch {
    return false;
  }
}

async function notifyDiscord(text) {
  if (!DISCORD_URL) return;
  await fetch(DISCORD_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ content: text }),
  }).catch(() => {});
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', c => chunks.push(c));
    req.on('end',  () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

// ── Deploy ───────────────────────────────────────────────────────────────────

function triggerDeploy(payload) {
  deploying    = true;
  lastDeployAt = Date.now();

  log({ event: 'deploy.started', image: payload.image, env: payload.env, sha: payload.sha });
  notifyDiscord(`🚀 **Deploy iniciado**\nImagem: \`${payload.image}\`\nAmbiente: \`${payload.env}\``);

  const args = [payload.image, payload.env];
  execFile(DEPLOY_SCRIPT, args, { timeout: 300_000 }, (err, stdout, stderr) => {
    deploying = false;

    if (err) {
      log({ event: 'deploy.failed', image: payload.image, error: err.message });
      notifyDiscord(
        `❌ **Deploy FALHOU**\nImagem: \`${payload.image}\`\n` +
        `\`\`\`\n${stderr.slice(0, 1500)}\n\`\`\``
      );
    } else {
      log({ event: 'deploy.success', image: payload.image, env: payload.env });
      notifyDiscord(`✅ **Deploy OK**\nImagem: \`${payload.image}\` → \`${payload.env}\``);
    }
  });
}

// ── Servidor HTTP ────────────────────────────────────────────────────────────

const server = http.createServer(async (req, res) => {
  // Health / status (sem auth — para o nginx e monitoring)
  if (req.method === 'GET' && req.url === '/health') {
    return res.writeHead(200, { 'Content-Type': 'application/json' })
      .end(JSON.stringify({ ok: true }));
  }

  if (req.method === 'GET' && req.url === '/status') {
    return res.writeHead(200, { 'Content-Type': 'application/json' })
      .end(JSON.stringify({ deploying, lastDeployAt }));
  }

  // Endpoint principal
  if (req.method === 'POST' && req.url === '/deploy') {
    const body = await readBody(req).catch(() => null);
    if (!body) return res.writeHead(400).end('Bad request');

    if (!verifyHmac(body.toString(), req.headers['x-hub-signature-256'])) {
      log({ event: 'deploy.rejected', reason: 'invalid_signature' });
      return res.writeHead(401).end('Unauthorized');
    }

    if (deploying)                         return res.writeHead(409).end('Deploy em andamento');
    if (Date.now() - lastDeployAt < RATE_LIMIT_MS) return res.writeHead(429).end('Rate limited');

    let payload;
    try { payload = JSON.parse(body.toString()); } catch { return res.writeHead(400).end('JSON inválido'); }

    if (!payload?.image || !payload?.env) return res.writeHead(400).end('image e env obrigatórios');

    res.writeHead(202).end('Deploy aceito');
    triggerDeploy(payload);
    return;
  }

  res.writeHead(404).end('Not found');
});

server.listen(PORT, '127.0.0.1', () =>
  console.log(`Receiver ouvindo em 127.0.0.1:${PORT}`)
);
