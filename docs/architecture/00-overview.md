# 00 — Overview

## 1. Visão

MaestroFinanças é um ecossistema híbrido (App Mobile + Web/PWA) de gestão
financeira que unifica a Pessoa Física (PF) do usuário e N Pessoas
Jurídicas (PJ) em um mesmo dashboard. O diferencial não é o lançamento
manual de despesas — é **consolidar automaticamente** o que já existe nos
bancos (via Open Finance), traduzir isso em **indicadores de saúde
financeira**, e oferecer **ações operacionais** (orçamentos, cobranças,
agenda) no mesmo lugar.

## 2. Stakeholders e perfis

| Perfil | Descrição | Acesso típico |
|--------|-----------|---------------|
| Titular | Dono da conta (PF + 1..N PJs) | Full em todos os contextos |
| Sócio | Co-administrador de uma PJ | Full em uma PJ específica |
| Contador | Prestador externo | Read/write contábil em PJ(s) autorizada(s) |
| Colaborador | Operacional (ex: lançar boletos) | Escopo muito reduzido por tela |
| Visualizador | Consulta (ex: cônjuge, auditor) | Somente leitura em contextos definidos |

Todas as permissões são granulares **por contexto (PF ou PJ específica) ×
por tela/ação** — ver [07-rbac.md](07-rbac.md).

## 3. Conceitos-chave

- **Contexto**: uma PF ou uma PJ individual. Cada lançamento pertence a
  exatamente um contexto.
- **Seletor de Contexto**: widget global (topo do app) que alterna entre
  contextos individuais ou o modo **Unificado**.
- **Dashboard Unificado**: agregação somada de todos os contextos que o
  usuário tem permissão de ver, com *tags visuais* (cor/ícone) para
  identificar a origem.
- **Dinheiro Livre**: saldo disponível descontadas as obrigações fixas e
  parcelamentos até o próximo vencimento — ver
  [03-intelligence-engine.md](03-intelligence-engine.md).
- **Reserva de Emergência Ideal**: múltiplo da média móvel dos gastos
  fixos, com banda 3×–6× ajustada por estabilidade de renda.
- **Insight**: card acionável gerado pela engine de inteligência (ex:
  "você vai ficar negativo em 47 dias se nada mudar").

## 4. Princípios de arquitetura

1. **Multi-tenancy lógico, não físico.** Um único banco PostgreSQL,
   isolamento via Row-Level Security + `tenant_id`. Simples, auditável,
   econômico; escala para dezenas de milhares de contextos antes de
   exigir sharding.
2. **Stateless services, stateful storage.** Qualquer pod pode ser morto
   e substituído; estado vive em Postgres, Redis, S3.
3. **Eventos antes de cron.** Conciliação, insights, notificações viajam
   por filas (RabbitMQ). Cron só para agendamentos de negócio (ex:
   recálculo diário de projeções).
4. **Defesa em profundidade.** Tokens bancários nunca saem do
   *cofre* sem descriptografia sob demanda. Logs de auditoria são
   append-only.
5. **LGPD by design.** Minimização de dados, consentimento explícito por
   integração, direito ao esquecimento implementável com uma única
   operação transacional.
6. **Glassmorphism não é decoração** — é linguagem de *profundidade
   informacional*. Camadas translúcidas reforçam hierarquia: resumo à
   frente, detalhe ao fundo, contexto sempre visível.

## 5. Escopo do MVP vs. futuro

| Feature | MVP | Fase 2 | Fase 3 |
|---------|-----|--------|--------|
| Seletor de Contexto + Dashboard Unificado | ✅ | | |
| Import OFX/OFC/XLS manual | ✅ | | |
| Open Finance (Pluggy) | ✅ | | |
| Categorização por regras | ✅ | | |
| Categorização por ML | | ✅ | |
| Reserva de Emergência + Dinheiro Livre | ✅ | | |
| Projeção 30/60/90 dias | ✅ | | |
| Monte Carlo + cenários | | ✅ | |
| Emissão de boletos | | ✅ | |
| Orçamentos/propostas | ✅ (básico) | ✅ (templates) | |
| Investimentos (posições consolidadas) | | ✅ | |
| Recomendador de investimentos | | | ✅ |
| Módulo fiscal (DAS, IRPF pré-preenchido) | | | ✅ |

## 6. Glossário

- **PF**: Pessoa Física.
- **PJ**: Pessoa Jurídica.
- **OFX/OFC**: formatos padrão de extrato bancário.
- **RBAC**: Role-Based Access Control.
- **RLS**: Row-Level Security (PostgreSQL).
- **MFA**: Multi-Factor Authentication.
- **KMS**: Key Management Service (para rotação de chaves de
  criptografia).
- **SLA**: Service Level Agreement.
- **p95/p99**: percentis de latência.
