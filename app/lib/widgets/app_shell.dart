import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/app_tool.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'animated_background.dart';
import 'app_ui.dart';
import 'version_badge.dart';

const _kCollapsed = 64.0;
const _kExpanded = 240.0;
const _kDesktopBreak = 900.0;

/// Shell compartilhado por TODAS as telas logadas (/app e /app/*).
///
/// Fornece:
/// - Sidebar esquerda (permanente no desktop, drawer no mobile) com
///   todas as ferramentas + botão "Todos os apps" + versão
/// - Top bar opcional com ícone + nome da ferramenta atual + slot trailing
/// - Dock inferior fixa com acesso rápido às 4 principais ferramentas
/// - Fundo animado (glass/água/vivo)
class AppShell extends StatefulWidget {
  /// ID da tela atual (p/ destacar no sidebar e esconder do dock).
  /// Use `'home'` para a home (nenhuma ferramenta ativa).
  final String currentId;

  /// Conteúdo principal da tela.
  final Widget content;

  /// Se `true`, mostra top bar com ícone + nome da ferramenta.
  /// `false` (default) para home, que já tem greeting próprio.
  final bool showTopBar;

  /// Widget no canto direito do top bar (ex: month selector).
  final Widget? trailing;

  /// FAB.
  final Widget? floatingActionButton;

  const AppShell({
    super.key,
    required this.currentId,
    required this.content,
    this.showTopBar = false,
    this.trailing,
    this.floatingActionButton,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _expanded = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AppTool? get _currentTool {
    if (widget.currentId == 'home') return null;
    return appTools.firstWhere(
      (t) => t.id == widget.currentId,
      orElse: () => AppTool(
        id: widget.currentId,
        name: widget.currentId,
        subtitle: '',
        icon: Icons.category_rounded,
        color: AppColors.textSecondary,
        route: '/app/${widget.currentId}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >= _kDesktopBreak;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bg1,
      drawer: isDesktop ? null : _MobileDrawer(currentId: widget.currentId),
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
            children: [
              isDesktop ? _buildDesktop() : _buildMobile(),
              // FAB manualmente posicionado acima do dock (~86px de altura)
              if (widget.floatingActionButton != null)
                Positioned(
                  right: AppSpacing.md,
                  bottom: 96,
                  child: widget.floatingActionButton!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Desktop: sidebar fixa à esquerda ────────────────────────────────────
  Widget _buildDesktop() {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          width: _expanded ? _kExpanded : _kCollapsed,
          child: _DesktopSidebar(
            expanded: _expanded,
            currentId: widget.currentId,
            onToggle: () => setState(() => _expanded = !_expanded),
          ),
        ),
        const VerticalDivider(width: 1, color: AppColors.glassBorder),
        Expanded(
          child: Column(
            children: [
              if (widget.showTopBar && _currentTool != null)
                _TopBar(
                  tool: _currentTool!,
                  trailing: widget.trailing,
                  showMenu: false,
                  onMenu: () {},
                ),
              Expanded(child: widget.content),
              const _QuickDock(),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Mobile: drawer + coluna ─────────────────────────────────────────────
  Widget _buildMobile() {
    return Column(
      children: [
        if (widget.showTopBar && _currentTool != null)
          _TopBar(
            tool: _currentTool!,
            trailing: widget.trailing,
            showMenu: true,
            onMenu: () => _scaffoldKey.currentState?.openDrawer(),
          )
        else
          // Home sem top bar: ainda precisa de hamburger para abrir drawer
          _HomeBar(
              onMenu: () => _scaffoldKey.currentState?.openDrawer()),
        Expanded(child: widget.content),
        const _QuickDock(),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Dock inferior — 4 acessos rápidos
// ════════════════════════════════════════════════════════════════════════════

class _QuickDock extends StatelessWidget {
  const _QuickDock();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        radius: AppRadius.xxl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Atalho p/ tela inicial (antes ficava na sidebar)
            _DockItem(
              icon: Icons.apps_rounded,
              label: 'Início',
              color: AppColors.accent3,
              onTap: () => context.go('/app'),
            ),
            ...dockTools.map((tool) => _DockItem(
                  icon: tool.icon,
                  label: tool.name,
                  color: tool.color,
                  onTap: () => context.go(tool.route),
                )),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconBadge(
              icon: icon,
              color: color,
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(height: 4),
            Text(label,
                style: AppTypo.labelSmall
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Home bar (mobile) — hamburger + título quando estamos no /app
// ════════════════════════════════════════════════════════════════════════════

class _HomeBar extends StatelessWidget {
  final VoidCallback onMenu;
  const _HomeBar({required this.onMenu});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded,
                color: AppColors.textSecondary, size: 22),
            onPressed: onMenu,
            tooltip: 'Menu',
          ),
          const SizedBox(width: AppSpacing.xs),
          const AppIconBadge(
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.accent1,
            size: 28,
            iconSize: 14,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('Maestro', style: AppTypo.titleSmall),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Desktop sidebar
// ════════════════════════════════════════════════════════════════════════════

class _DesktopSidebar extends StatelessWidget {
  final bool expanded;
  final String currentId;
  final VoidCallback onToggle;

  const _DesktopSidebar({
    required this.expanded,
    required this.currentId,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.55),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: expanded ? AppSpacing.md : 0),
                child: Row(
                  mainAxisAlignment: expanded
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_rounded,
                        color: AppColors.textSecondary, size: 22),
                    if (expanded) ...[
                      const SizedBox(width: AppSpacing.smd),
                      Text('Maestro', style: AppTypo.titleSmall),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const AppDivider(),
          const SizedBox(height: AppSpacing.xs),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + 2, vertical: 2),
              children: appTools
                  .where((t) => t.id != 'settings')
                  .map((tool) {
                return _SidebarItem(
                  tool: tool,
                  active: tool.id == currentId,
                  expanded: expanded,
                  onTap: () => context.go(tool.route),
                );
              }).toList(),
            ),
          ),

          const AppDivider(),
          _SettingsItem(
            expanded: expanded,
            active: currentId == 'settings',
            onTap: () => context.go('/app/settings'),
          ),
          if (expanded)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: VersionBadge(fontSize: 9),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Mobile drawer
// ════════════════════════════════════════════════════════════════════════════

class _MobileDrawer extends StatelessWidget {
  final String currentId;

  const _MobileDrawer({required this.currentId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Opacidade alta para leitura clara (sem conflito com a tela atrás)
      backgroundColor: const Color(0xFFF0F4FA),
      elevation: 8,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen),
              child: Row(
                children: [
                  const AppIconBadge(
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.accent1,
                    size: 30,
                    iconSize: 16,
                  ),
                  const SizedBox(width: AppSpacing.smd),
                  Text('Maestro Finanças', style: AppTypo.titleSmall),
                ],
              ),
            ),
            const AppDivider(),
            const SizedBox(height: AppSpacing.xs),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 2),
                children: appTools
                    .where((t) => t.id != 'settings')
                    .map((tool) {
                  return _SidebarItem(
                    tool: tool,
                    active: tool.id == currentId,
                    expanded: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(tool.route);
                    },
                  );
                }).toList(),
              ),
            ),

            const AppDivider(),
            _SettingsItem(
              expanded: true,
              active: currentId == 'settings',
              onTap: () {
                Navigator.pop(context);
                context.go('/app/settings');
              },
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: VersionBadge(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Sidebar item
// ════════════════════════════════════════════════════════════════════════════

class _SidebarItem extends StatelessWidget {
  final AppTool tool;
  final bool active;
  final bool expanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.tool,
    required this.active,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? AppSpacing.smd : 0,
          vertical: AppSpacing.smd - 2,
        ),
        decoration: BoxDecoration(
          color: active
              ? tool.color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: active
                ? tool.color.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: expanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(tool.icon,
                color: active ? tool.color : AppColors.textSecondary,
                size: 20),
            if (expanded) ...[
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Text(
                  tool.name,
                  style: AppTypo.bodySmall.copyWith(
                    color: active
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: active
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Configurações (sidebar footer)
// ════════════════════════════════════════════════════════════════════════════

class _SettingsItem extends StatelessWidget {
  final bool expanded;
  final bool active;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.expanded,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const color = AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.xs + 2),
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? AppSpacing.smd : 0,
          vertical: AppSpacing.smd - 1,
        ),
        decoration: BoxDecoration(
          color: active
              ? AppColors.textSecondary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: active
                ? AppColors.textSecondary.withValues(alpha: 0.3)
                : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: expanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_rounded, color: color, size: 20),
            if (expanded) ...[
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Text(
                  'Configurações',
                  style: AppTypo.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Top bar (mostrado em tool screens)
// ════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final AppTool tool;
  final Widget? trailing;
  final bool showMenu;
  final VoidCallback onMenu;

  const _TopBar({
    required this.tool,
    required this.trailing,
    required this.showMenu,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              icon: const Icon(Icons.menu_rounded,
                  color: AppColors.textSecondary, size: 22),
              onPressed: onMenu,
              tooltip: 'Menu',
            )
          else
            const SizedBox(width: AppSpacing.md),
          AppIconBadge(
            icon: tool.icon,
            color: tool.color,
            size: 30,
            iconSize: 16,
          ),
          const SizedBox(width: AppSpacing.smd),
          Text(tool.name, style: AppTypo.titleSmall),
          const Spacer(),
          if (trailing != null) trailing!,
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}
