# 02 — Desenho do Sistema

## 1. Visão de alto nível (C4 nível 2 — containers)

```mermaid
flowchart TB
    subgraph Client["Clientes"]
        MobileApp["Flutter App<br/>(iOS · Android)"]
        WebPWA["Flutter Web / PWA"]
    end

    subgraph Edge["Borda"]
        CDN["CDN + WAF<br/>(Cloudflare)"]
        GW["API Gateway<br/>(Traefik/Kong)<br/>TLS · rate-limit · mTLS interno"]
    end

    subgraph Core["Microserviços de Núcleo (NestJS)"]
        AUTH["Auth Service<br/>OAuth2 · JWT · MFA"]
        FIN["Financial Service<br/>lançamentos · categorias"]
        OF["Open Finance Service<br/>Pluggy/Belvo · conciliação"]
        OPS["Operations Service<br/>agenda · orçamentos · boletos"]
        NOTIF["Notifications Service<br/>push · email · in-app"]
        FILES["Files Service<br/>anexos · assinatura S3"]
    end

    subgraph AI["Inteligência"]
        INSIGHT["Insights Engine (Python)<br/>categorização ML · projeções"]
    end

    subgraph Data["Dados e Estado"]
        PG[("PostgreSQL 16<br/>RLS por tenant")]
        REDIS[("Redis 7<br/>cache · BullMQ")]
        MQ[("RabbitMQ<br/>eventos")]
        S3[("Object Storage<br/>S3-compatible")]
        VAULT[("Vault / KMS<br/>chaves AES-256")]
    end

    subgraph External["Terceiros"]
        PLUGGY["Pluggy / Belvo<br/>(Open Finance)"]
        FCM["FCM / APNs"]
        SMTP["SMTP (SES)"]
        BOLETO["Banco emissor<br/>(boletos)"]
    end

    MobileApp -->|HTTPS| CDN
    WebPWA -->|HTTPS| CDN
    CDN --> GW

    GW --> AUTH
    GW --> FIN
    GW --> OF
    GW --> OPS
    GW --> FILES
    GW -->|GraphQL agregador| FIN

    AUTH --> PG
    AUTH --> REDIS
    AUTH --> VAULT
    FIN --> PG
    FIN --> REDIS
    FIN --> MQ
    OF --> PG
    OF --> MQ
    OF --> VAULT
    OF <-->|webhooks + REST| PLUGGY
    OPS --> PG
    OPS --> MQ
    OPS <--> BOLETO
    FILES --> S3
    FILES --> PG

    MQ --> INSIGHT
    INSIGHT --> PG
    INSIGHT --> MQ

    MQ --> NOTIF
    NOTIF --> FCM
    NOTIF --> SMTP
    NOTIF --> REDIS
```

## 2. Fluxo canônico: conciliação via Open Finance

```mermaid
sequenceDiagram
    autonumber
    participant U as Usuário (App)
    participant GW as API Gateway
    participant OF as Open Finance Svc
    participant V as Vault (KMS)
    participant P as Pluggy
    participant MQ as RabbitMQ
    participant FIN as Financial Svc
    participant INS as Insights Engine
    participant N as Notifications

    U->>GW: POST /open-finance/connections (bank + consent)
    GW->>OF: forward autenticado (JWT)
    OF->>P: cria connectToken + itemId
    P-->>OF: item_id + access_token (tokenizado)
    OF->>V: encrypt(access_token, AES-256-GCM)
    V-->>OF: ciphertext + keyId
    OF->>OF: persiste ciphertext em connections
    P-->>OF: webhook item/updated
    OF->>MQ: publish transactions.imported {itemId, ctxId}
    MQ->>FIN: consumer
    FIN->>FIN: dedupe (idempotencyKey) + categoriza por regras
    FIN->>MQ: publish transactions.categorized
    MQ->>INS: consumer
    INS->>INS: recalcula dinheiro livre, projeção 30/60/90
    INS->>MQ: publish insight.generated (se alerta)
    MQ->>N: consumer
    N-->>U: push notification (cash flow alert)
```

## 3. Fluxo: seleção de contexto e Dashboard Unificado

```mermaid
sequenceDiagram
    autonumber
    participant U as Usuário
    participant APP as Flutter App
    participant GW as API Gateway
    participant AUTH as Auth Svc
    participant FIN as Financial Svc (GraphQL)
    participant R as Redis (cache)
    participant PG as Postgres

    U->>APP: seleciona "Unificado"
    APP->>GW: POST /auth/context { scope: "unified" }
    GW->>AUTH: valida permissões (RBAC)
    AUTH-->>APP: JWT curto com claim ctx=unified + allowedTenants=[..]
    APP->>GW: GraphQL dashboard(range: "90d")
    GW->>FIN: forward com JWT
    FIN->>R: GET dashboard:{userId}:unified:90d
    alt cache miss
        FIN->>PG: SET LOCAL app.current_tenant_ids = ARRAY[..]
        FIN->>PG: consolidated queries (materialized views)
        PG-->>FIN: agregados com tag origem
        FIN->>R: SETEX 60s
    end
    FIN-->>APP: resposta com tags visuais
    APP->>U: Dashboard Unificado
```

## 4. Decomposição de microserviços

| Serviço | Responsabilidade | Dono de tabelas | Eventos que emite | Eventos que consome |
|---------|------------------|-----------------|-------------------|---------------------|
| **Auth** | Identidade, sessão, MFA, RBAC | `users`, `sessions`, `roles`, `permissions`, `memberships` | `user.created`, `role.changed` | — |
| **Financial** | Lançamentos, categorias, saldos, orçamento | `accounts`, `transactions`, `categories`, `rules`, `budgets` | `transaction.created`, `transaction.categorized`, `balance.changed` | `transactions.imported`, `transactions.matched` |
| **Open Finance** | Conexões bancárias, conciliação, import OFX/XLS | `connections`, `import_jobs`, `bank_matches` | `transactions.imported`, `connection.expired` | `connection.requested` |
| **Operations** | Agenda, orçamentos, propostas, recibos, boletos | `appointments`, `quotes`, `receipts`, `invoices`, `boletos` | `boleto.issued`, `boleto.paid`, `quote.accepted` | `transaction.categorized` (para baixa automática) |
| **Files** | Upload/download de anexos, OCR | `attachments` | `attachment.uploaded`, `ocr.completed` | — |
| **Insights (Python)** | Projeção, reserva ideal, dinheiro livre, ML categorização | `insights`, `ml_models`, `projections` | `insight.generated`, `projection.updated` | `transaction.categorized`, `balance.changed` |
| **Notifications** | Push, email, in-app, preferências | `notif_channels`, `notif_preferences` | `notification.delivered` | `insight.generated`, `boleto.paid`, etc. |

**Regra de ouro**: um serviço é dono exclusivo das suas tabelas. Outros
serviços leem via API ou consumindo eventos — *nunca* SQL direto
cross-service. Isso preserva a opção de extrair o serviço para seu
próprio banco no futuro.

## 5. Estratégia de mensageria

```mermaid
flowchart LR
    P[Producer] -->|publish| X((Exchange<br/>topic))
    X --> Q1[[queue.financial]]
    X --> Q2[[queue.insights]]
    X --> Q3[[queue.notifications]]
    X -.-> DLX((DLX<br/>dead-letter))
    Q1 -->|ack| C1[Financial Consumer]
    Q2 -->|ack| C2[Insights Consumer]
    Q3 -->|ack| C3[Notifications Consumer]
    C1 -.nack/timeout.-> DLX
```

- **Exchange topic** com routing keys estilo
  `transaction.categorized.ctx-<uuid>`.
- **Dead-letter exchange (DLX)** para mensagens que falham 3 vezes —
  inspecionadas por um job de auditoria.
- **Idempotência**: todo consumer verifica `idempotency_key`
  (geralmente `providerTxId` do Pluggy ou hash do OFX) antes de
  persistir, evitando duplicidade em *retries*.
- **Outbox pattern**: eventos são gravados em `event_outbox` na mesma
  transação que muda o estado do agregado; um *relay* publica no
  RabbitMQ. Garante *at-least-once* sem depender de XA.

## 6. API Gateway — responsabilidades

1. **Terminação TLS** e HTTP/3.
2. **Autenticação**: valida JWT de acesso, extrai `userId`, `contextId`,
   `allowedTenants`, `permissions`. Injeta headers `X-Tenant-Id` e
   `X-User-Id` (assinados) para os serviços internos.
3. **Rate-limit**: por usuário (100 req/min) e por IP (300 req/min).
   Buckets específicos para endpoints caros (dashboard unificado: 20
   req/min).
4. **WAF**: regras OWASP Top 10 + custom para SQLi em filtros.
5. **mTLS** para comunicação com serviços internos (certificados rotados
   por cert-manager).
6. **Observabilidade**: injeta `traceparent` W3C em toda requisição.

## 7. Estratégia de versionamento

- API pública: versão no path (`/v1/...`). Quebrar contrato exige `v2`.
- Eventos internos: campo `schemaVersion`. Consumers toleram N-1
  (compatibilidade progressiva).
- Banco: migrações *expand/contract* (nunca drop+create na mesma
  release).

## 8. Ambientes

| Ambiente | Propósito | Dados |
|----------|-----------|-------|
| `local` | dev (docker-compose) | mock + sandbox Pluggy |
| `dev` | integração contínua | sintéticos |
| `staging` | pré-prod espelhando prod | anonimizados |
| `prod` | produção | reais |

Promoção de release: `dev → staging → prod` via pipeline GitOps,
feature flags controladas por Unleash/Flagsmith.
