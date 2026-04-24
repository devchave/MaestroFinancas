# MaestroFinanças

> Ecossistema financeiro híbrido (App Mobile + Web) para gestão unificada de
> Pessoa Física e múltiplas Pessoas Jurídicas, com foco em saúde financeira,
> planejamento estratégico e investimentos.

Este repositório ainda está em fase de desenho arquitetural. O código-fonte
será introduzido nas próximas iterações, fundamentado nos documentos abaixo.

## Filosofia de Design

Clareza, transparência e controle total. Visual inspirado no *Glassmorphism*
do iOS: painéis semi-transparentes flutuando sobre um fundo abstrato de água
cristalina em movimento, onde os reflexos de luz trazem dinamismo e fluidez.

## Pilares Funcionais

- **Visão Consolidada Híbrida (PF + PJs)** com Seletor de Contexto e
  Dashboard Unificado.
- **Open Finance** (Pluggy / Belvo) com conciliação bancária automática
  (OFX / OFC / XLS) e ações em lote.
- **Consultor de Saúde Financeira** com IA/heurísticas (reserva de
  emergência, dinheiro livre, alertas 30/60/90 dias).
- **Módulo Operacional**: agenda, orçamentos, propostas, recibos, boletos,
  anexos.
- **RBAC granular** por empresa e por tela.

## Índice da Arquitetura

| # | Documento | Conteúdo |
|---|-----------|----------|
| 00 | [Overview](docs/architecture/00-overview.md) | Escopo, filosofia, glossário |
| 01 | [Stack Tecnológica](docs/architecture/01-tech-stack.md) | App, Backend, DB, trade-offs |
| 02 | [Desenho do Sistema](docs/architecture/02-system-design.md) | Microserviços, mensageria, diagramas |
| 03 | [Engine de Inteligência](docs/architecture/03-intelligence-engine.md) | Indicadores, categorização, insights |
| 04 | [Segurança & LGPD](docs/architecture/04-security.md) | AES-256-GCM, OAuth2, MFA, biometria |
| 05 | [Escalabilidade & Infra](docs/architecture/05-scalability-infra.md) | Hostinger, S3, autoscaling |
| 06 | [Modelo de Dados](docs/architecture/06-data-model.md) | Schema + multi-tenancy via RLS |
| 07 | [RBAC Granular](docs/architecture/07-rbac.md) | Matriz de permissões |

## Status

- [x] Briefing de produto
- [x] Arquitetura de referência (este pacote)
- [ ] Protótipo de UI (Glassmorphism + fundo em movimento)
- [ ] MVP backend (Auth + Financeiro + Open Finance)
- [ ] Integração Pluggy/Belvo sandbox
- [ ] Engine de insights v1
- [ ] Beta fechado

## Licença

A definir.
