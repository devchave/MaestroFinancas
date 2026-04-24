# 01 — Stack Tecnológica

## 1. App (iOS + Android + Web/PWA) — Flutter

**Escolha: Flutter 3.x + Dart.**

### Por que Flutter e não React Native?

| Critério | Flutter | React Native |
|----------|---------|--------------|
| Um único codebase para iOS/Android/Web | ✅ nativo | ⚠️ web via RN-Web, limitado |
| Renderização custom (Glassmorphism, fundo líquido) | ✅ Skia/Impeller, shaders GLSL diretos | ⚠️ depende de bridge + libs nativas |
| Performance de animações 60–120fps | ✅ compositor próprio | ⚠️ bridge JS pode tremer |
| Biometria / MFA / deep-link | ✅ `local_auth`, `flutter_appauth` | ✅ equivalentes |
| Tamanho da comunidade fintech BR | ✅ grande (Nubank, Inter) | ✅ grande |
| Tipagem forte de ponta a ponta | ✅ Dart | ⚠️ depende de TS |

O fator decisivo é o **fundo abstrato de água em movimento com reflexos de
luz**. Isso pede *fragment shaders* customizados (GLSL) rodando a 60fps
em dispositivos modestos — o Impeller do Flutter expõe isso
nativamente via `FragmentProgram`. Em RN, o caminho é `react-native-skia`
(ok) ou bridges nativas (complexas). Flutter reduz custo de implementação
e risco de inconsistência visual entre plataformas.

### Pacotes centrais

- **Estado**: `riverpod` (testável, sem boilerplate de BLoC).
- **Navegação**: `go_router` com deep-links para contextos
  (`/ctx/:contextId/dashboard`).
- **HTTP/GraphQL**: `dio` + `graphql_flutter` (o backend expõe
  REST + GraphQL — ver §3).
- **Armazenamento seguro**: `flutter_secure_storage` (Keychain iOS /
  Keystore Android) para refresh tokens.
- **Biometria**: `local_auth` + fallback PIN.
- **Gráficos**: `fl_chart` (flexível e customizável para o visual
  translúcido).
- **Offline-first**: `drift` (SQLite type-safe) para cache de lançamentos
  e sincronização posterior.
- **PWA**: build `flutter build web --wasm` + service worker para cache
  de assets e estratégia *stale-while-revalidate* para dados leves.

### Design System

Um pacote interno `maestro_ui` com tokens (cores, blur radius, elevações),
o widget `GlassPanel` (envelope padrão com `BackdropFilter` +
`ImageFilter.blur`), e o `LiquidBackground` (shader GLSL parametrizável
por hora do dia).

## 2. Backend — Node.js + TypeScript (NestJS)

**Escolha: Node.js 22 LTS + TypeScript 5.x + NestJS 11.**

### Por que Node/NestJS e não Python/FastAPI?

| Critério | Node/NestJS | Python/FastAPI |
|----------|-------------|----------------|
| Concorrência I/O-bound (Open Finance, webhooks) | ✅ event loop | ✅ asyncio |
| Ecossistema fintech BR (boletos, NFe, OFX) | ✅ maduro (`ofx-js`, `boleto-nodejs`) | ⚠️ mais escasso |
| Compartilhamento de tipos com o app (Dart) | ⚠️ via OpenAPI | ⚠️ via OpenAPI (empate) |
| Processamento pesado (ML de categorização) | ⚠️ chama serviço Python | ✅ nativo |
| Parsing de planilhas (XLS/XLSX) | ✅ `exceljs`, streaming | ✅ `openpyxl`, menos stream |
| Latência média de endpoints CRUD | ✅ ótima | ✅ ótima |

**Decisão híbrida**: NestJS para o núcleo transacional (Auth, Financeiro,
Open Finance, Operacional, Notificações), **e um microserviço Python
dedicado à Engine de Inteligência** (scikit-learn / Prophet / XGBoost),
comunicando via RabbitMQ. O melhor dos dois mundos sem adotar dois
stacks generalistas.

### Por que NestJS e não Express puro?

- Módulos + DI nativa facilitam separar microserviços que hoje vivem
  em monorepo (ver [02-system-design.md](02-system-design.md)).
- Suporte oficial a **transports** (HTTP, gRPC, RabbitMQ, Kafka, Redis)
  — trocamos o transporte sem reescrever handlers.
- `class-validator` / `class-transformer` garantem DTOs validados antes
  de tocar a camada de domínio.

### Bibliotecas-chave

- **ORM**: Prisma (schema declarativo, migrações versionadas,
  suporte a RLS via `$queryRaw` e session vars).
- **Fila**: `@nestjs/microservices` + RabbitMQ (`amqplib`).
- **Cache / rate-limit**: Redis + `@nestjs/throttler`.
- **Jobs agendados**: BullMQ (Redis) — separado das filas de domínio.
- **Observabilidade**: OpenTelemetry → traces em Grafana Tempo, métricas
  em Prometheus, logs estruturados (pino) em Loki.
- **Tests**: Jest + Testcontainers (Postgres real em CI).

## 3. API — REST + GraphQL

- **REST** para operações transacionais, webhooks (Open Finance) e
  uploads multipart (OFX/XLS, anexos).
- **GraphQL** (Apollo + Dataloader) para leitura do dashboard: o cliente
  especifica exatamente o que quer ver do Seletor de Contexto ativo,
  evitando N+1 e *overfetch*. Essencial quando o Dashboard Unificado
  soma 5–10 contextos simultaneamente.

Contrato único gerado por OpenAPI 3.1 + GraphQL SDL; o app Flutter
consome via código gerado (`openapi-generator` + `graphql_codegen`).

## 4. Banco de Dados

**Principal: PostgreSQL 16** (gerenciado, ver
[05-scalability-infra.md](05-scalability-infra.md)).

### Multi-tenancy — estratégia escolhida

**Shared DB, shared schema, Row-Level Security (RLS) por `tenant_id`**.

Comparativo:

| Estratégia | Prós | Contras | Decisão |
|-----------|------|---------|---------|
| DB por tenant | Isolamento máximo | Migrações N×, custo, backup por tenant | ❌ |
| Schema por tenant | Isolamento bom | Milhares de schemas travam `pg_catalog` | ❌ |
| Shared + `tenant_id` sem RLS | Simples | Um bug de WHERE vaza dados entre tenants | ❌ |
| **Shared + RLS** | Isolamento no banco + simplicidade | Exige disciplina com `SET LOCAL app.tenant_id` | ✅ |

Cada request autenticado abre transação com:

```sql
SET LOCAL app.current_tenant_id = '<uuid>';
SET LOCAL app.current_user_id   = '<uuid>';
```

Todas as tabelas sensíveis têm policy:

```sql
CREATE POLICY tenant_isolation ON transactions
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
```

Ver esquema detalhado em [06-data-model.md](06-data-model.md).

### Extensões usadas

- `pgcrypto` — hashing e UUIDs.
- `pg_partman` — particionamento mensal da tabela `transactions`.
- `timescaledb` (opcional, fase 2) — hypertables para séries financeiras.
- `pg_trgm` — busca fuzzy em descrições de transações.

### Complementares

- **Redis 7**: cache de sessões, rate-limit, filas BullMQ, pub/sub para
  invalidação de cache de dashboard.
- **RabbitMQ 3.13**: mensageria de domínio (eventos entre microserviços).
- **S3-compatible** (MinIO em dev, Hostinger Object Storage em prod):
  anexos (comprovantes, PDFs de orçamento), backups lógicos.
- **OpenSearch** (fase 2): busca full-text em transações e anexos.

## 5. Resumo da Stack

```
┌──────────────────────────────────────────────────────────┐
│  Flutter (iOS, Android, Web/PWA)   —  Dart + Riverpod    │
├──────────────────────────────────────────────────────────┤
│  API Gateway  —  Traefik / Kong (TLS, WAF, rate-limit)   │
├──────────────────────────────────────────────────────────┤
│  Microserviços — NestJS (TS) + 1 serviço Python (IA)     │
├──────────────────────────────────────────────────────────┤
│  Mensageria — RabbitMQ     │  Cache / Jobs — Redis       │
├────────────────────────────┴─────────────────────────────┤
│  PostgreSQL 16 (RLS) + S3 (anexos) + Vault (KMS)         │
└──────────────────────────────────────────────────────────┘
```
