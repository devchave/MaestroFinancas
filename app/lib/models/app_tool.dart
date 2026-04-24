import 'package:flutter/material.dart';

class AppTool {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const AppTool({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

final List<AppTool> appTools = [
  AppTool(
    id: 'dashboard',
    name: 'Visão Geral',
    subtitle: 'Resumo consolidado',
    icon: Icons.bar_chart_rounded,
    color: const Color(0xFF0EA5E9),
    route: '/tools/dashboard',
  ),
  AppTool(
    id: 'wallet',
    name: 'Carteira',
    subtitle: 'Saldos e patrimônio',
    icon: Icons.account_balance_wallet_rounded,
    color: const Color(0xFF10B981),
    route: '/tools/wallet',
  ),
  AppTool(
    id: 'transactions',
    name: 'Transações',
    subtitle: 'Entradas e saídas',
    icon: Icons.swap_horiz_rounded,
    color: const Color(0xFF6366F1),
    route: '/tools/transactions',
  ),
  AppTool(
    id: 'accounts',
    name: 'Contas',
    subtitle: 'Bancos e contas',
    icon: Icons.account_balance_rounded,
    color: const Color(0xFF06B6D4),
    route: '/tools/accounts',
  ),
  AppTool(
    id: 'cards',
    name: 'Cartões',
    subtitle: 'Crédito e débito',
    icon: Icons.credit_card_rounded,
    color: const Color(0xFFF59E0B),
    route: '/tools/cards',
  ),
  AppTool(
    id: 'budget',
    name: 'Orçamento',
    subtitle: 'Metas e limites',
    icon: Icons.pie_chart_rounded,
    color: const Color(0xFFEC4899),
    route: '/tools/budget',
  ),
  AppTool(
    id: 'investments',
    name: 'Investimentos',
    subtitle: 'Carteira de ativos',
    icon: Icons.trending_up_rounded,
    color: const Color(0xFF8B5CF6),
    route: '/tools/investments',
  ),
  AppTool(
    id: 'invoices',
    name: 'Notas Fiscais',
    subtitle: 'NF-e e recibos',
    icon: Icons.receipt_long_rounded,
    color: const Color(0xFF14B8A6),
    route: '/tools/invoices',
  ),
  AppTool(
    id: 'companies',
    name: 'Empresas',
    subtitle: 'Gestão PJ',
    icon: Icons.business_rounded,
    color: const Color(0xFF3B82F6),
    route: '/tools/companies',
  ),
  AppTool(
    id: 'employees',
    name: 'Funcionários',
    subtitle: 'Folha e RH',
    icon: Icons.people_rounded,
    color: const Color(0xFFF97316),
    route: '/tools/employees',
  ),
  AppTool(
    id: 'insights',
    name: 'Insights IA',
    subtitle: 'Análise inteligente',
    icon: Icons.auto_awesome_rounded,
    color: const Color(0xFFA855F7),
    route: '/tools/insights',
  ),
  AppTool(
    id: 'settings',
    name: 'Ajustes',
    subtitle: 'Configurações',
    icon: Icons.settings_rounded,
    color: const Color(0xFF64748B),
    route: '/tools/settings',
  ),
];

final List<AppTool> dockTools = [
  appTools[0], // Visão Geral
  appTools[2], // Transações
  appTools[1], // Carteira
  appTools[10], // Insights IA
];
