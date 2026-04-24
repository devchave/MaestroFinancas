# MaestroFinanças

> Ecossistema financeiro híbrido (App Mobile + Web) para gestão unificada de
> Pessoa Física e múltiplas Pessoas Jurídicas, com foco em saúde financeira,
> planejamento estratégico e investimentos.

## Filosofia de Design

Clareza, transparência e controle total. Visual inspirado no **Glassmorphism**
do iOS: painéis semi-transparentes flutuando sobre um fundo abstrato de água
cristalina em movimento, onde os reflexos de luz trazem dinamismo e fluidez.

## Pilares Funcionais

| Pilar | Descrição |
|-------|-----------|
| **Visão Consolidada** | Seletor de Contexto: alterna entre PF, PJ individual ou Dashboard Unificado |
| **Open Finance** | Pluggy / Belvo — conciliação automática OFX / OFC / XLS |
| **Saúde Financeira** | Reserva de emergência, Dinheiro Livre, projeção 30/60/90 dias |
| **Módulo Operacional** | Agenda, orçamentos, propostas, recibos, boletos, anexos |
| **Acesso Granular** | RBAC por empresa × tela × ação (ex: contador vê PJ, não a PF) |

## Índice da Arquitetura

| Doc | Conteúdo |
|-----|----------|
| [00 · Visão Geral](architecture/00-overview.md) | Escopo, stakeholders, glossário |
| [01 · Stack Tecnológica](architecture/01-tech-stack.md) | Flutter · NestJS · PostgreSQL RLS |
| [02 · Desenho do Sistema](architecture/02-system-design.md) | Microserviços, diagramas C4 |
| [03 · Engine de Inteligência](architecture/03-intelligence-engine.md) | Indicadores, categorização, insights |
| [04 · Segurança & LGPD](architecture/04-security.md) | AES-256-GCM, OAuth2, MFA, biometria |
| [05 · Escalabilidade & Infra](architecture/05-scalability-infra.md) | Hostinger, k3s, SLO, DR |
| [06 · Modelo de Dados](architecture/06-data-model.md) | ER, RLS, partições, índices |
| [07 · RBAC Granular](architecture/07-rbac.md) | Matriz de permissões |
| [08 · CI/CD & Deploy](architecture/08-cicd-deploy.md) | Webhook-pull, deploy.sh, rollback |

## Status do Projeto

- [x] Briefing de produto
- [x] Arquitetura de referência (este site)
- [x] Estratégia CI/CD & auto-deploy
- [ ] Protótipo UI (Glassmorphism + fundo em movimento)
- [ ] MVP backend (Auth · Financeiro · Open Finance)
- [ ] Integração Pluggy/Belvo sandbox
- [ ] Engine de insights v1
- [ ] Beta fechado
