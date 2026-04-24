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

/// Scaffold compartilhado por todas as telas de ferramenta.
/// Desktop (≥900px): sidebar permanente colapsável via hamburger.
/// Mobile (<900px): sidebar vira Drawer abrível pelo hamburger do top bar.
class ToolScaffold extends StatefulWidget {
  final String toolId;
  final Widget content;
  final Widget? trailing;
  final Widget? floatingActionButton;

  const ToolScaffold({
    super.key,
    required this.toolId,
    required this.content,
    this.trailing,
    this.floatingActionButton,
  });

  @override
  State<ToolScaffold> createState() => _ToolScaffoldState();
}

class _ToolScaffoldState extends State<ToolScaffold> {
  bool _expanded = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AppTool get _tool => appTools.firstWhere(
        (t) => t.id == widget.toolId,
        orElse: () => AppTool(
          id: widget.toolId,
          name: widget.toolId,
          subtitle: '',
          icon: Icons.category_rounded,
          color: AppColors.textSecondary,
          route: '/app/${widget.toolId}',
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreak;
    final tool = _tool;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bg1,
      drawer: isDesktop ? null : _MobileDrawer(currentId: widget.toolId),
      floatingActionButton: widget.floatingActionButton,
      body: AnimatedBackground(
        child: SafeArea(
          child: isDesktop
              ? Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      width: _expanded ? _kExpanded : _kCollapsed,
                      child: _DesktopSidebar(
                        expanded: _expanded,
                        currentId: widget.toolId,
                        onToggle: () =>
                            setState(() => _expanded = !_expanded),
                      ),
                    ),
                    const VerticalDivider(
                        width: 1, color: AppColors.glassBorder),
                    Expanded(
                      child: Column(
                        children: [
                          _TopBar(
                            tool: tool,
                            trailing: widget.trailing,
                            showMenu: false,
                            onMenu: () {},
                          ),
                          Expanded(child: widget.content),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _TopBar(
                      tool: tool,
                      trailing: widget.trailing,
                      showMenu: true,
                      onMenu: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(child: widget.content),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Desktop sidebar ──────────────────────────────────────────────────────────

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
      // Tom levemente mais escuro que bg1 para criar profundidade
      color: const Color(0xFF060A14),
      child: Column(
        children: [
          // Hamburger header
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
              children: appTools.map((tool) {
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
          _HomeItem(
            expanded: expanded,
            onTap: () => context.go('/app'),
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

// ─── Mobile drawer ────────────────────────────────────────────────────────────

class _MobileDrawer extends StatelessWidget {
  final String currentId;

  const _MobileDrawer({required this.currentId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF060A14),
      child: SafeArea(
        child: Column(
          children: [
            // Header com brand
            Container(
              height: 60,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
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
                children: appTools.map((tool) {
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
            _HomeItem(
              expanded: true,
              onTap: () {
                Navigator.pop(context);
                context.go('/app');
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

// ─── Sidebar item ─────────────────────────────────────────────────────────────

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
            Icon(
              tool.icon,
              color: active ? tool.color : AppColors.textSecondary,
              size: 20,
            ),
            if (expanded) ...[
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Text(
                  tool.name,
                  style: AppTypo.bodySmall.copyWith(
                    color: active
                        ? Colors.white
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

// ─── Home item ────────────────────────────────────────────────────────────────

class _HomeItem extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _HomeItem({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.xs + 2),
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? AppSpacing.smd : 0,
          vertical: AppSpacing.smd - 1,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: expanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            const Icon(Icons.apps_rounded,
                color: AppColors.accent1, size: 20),
            if (expanded) ...[
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Text(
                  'Todos os apps',
                  style: AppTypo.bodySmall.copyWith(
                    color: AppColors.accent1,
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

// ─── Top bar ──────────────────────────────────────────────────────────────────

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
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
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
