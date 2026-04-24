import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../models/app_tool.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/version_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  final _pageController = PageController();

  List<List<AppTool>> get _pages {
    final list = appTools
        .where((t) => !dockTools.any((d) => d.id == t.id))
        .toList();
    final pages = <List<AppTool>>[];
    for (var i = 0; i < list.length; i += 8) {
      pages.add(list.sublist(i, i + 8 > list.length ? list.length : i + 8));
    }
    return pages;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.smd),
              _GreetingBar().animate().fadeIn(delay: 200.ms),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen, AppSpacing.md, AppSpacing.screen, 0),
                child: _BalanceCard()
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.2, end: 0),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Grid paginado
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, pageIndex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screen),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.lg,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _pages[pageIndex].length,
                        itemBuilder: (context, i) {
                          final tool = _pages[pageIndex][i];
                          return _AppIcon(tool: tool)
                              .animate()
                              .fadeIn(
                                  delay: Duration(
                                      milliseconds: 100 + i * 60))
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                delay: Duration(
                                    milliseconds: 100 + i * 60),
                                duration: 300.ms,
                                curve: Curves.easeOutBack,
                              );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Indicador de página
              if (_pages.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? AppColors.accent1
                            : AppColors.glassBorder,
                        borderRadius:
                            BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.smd),
              _Dock(),
              const SizedBox(height: AppSpacing.sm),
              const VersionBadge(),
              const SizedBox(height: AppSpacing.smd),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Greeting ─────────────────────────────────────────────────────────────────

class _GreetingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Bom dia!'
        : (hour < 18 ? 'Boa tarde!' : 'Boa noite!');

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Olá, devchave',
                        style: AppTypo.bodySmall),
                    const SizedBox(width: 6),
                    Icon(
                      AppColors.isNight
                          ? Icons.nights_stay_rounded
                          : Icons.waving_hand_rounded,
                      color: AppColors.isNight
                          ? AppColors.accent3
                          : const Color(0xFFF59E0B),
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(greeting, style: AppTypo.headline),
              ],
            ),
          ),
          AppCard(
            padding: const EdgeInsets.all(2),
            radius: AppRadius.pill,
            child: CircleAvatar(
              radius: 20,
              backgroundColor:
                  AppColors.accent3.withValues(alpha: 0.4),
              child: Text('D',
                  style: AppTypo.titleSmall
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Balance card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.xl,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patrimônio total', style: AppTypo.bodySmall),
                const SizedBox(height: 4),
                Text('R\$ 48.320,00', style: AppTypo.numberLarge),
                const SizedBox(height: 6),
                StatusChip(
                  label: '+2,4% hoje',
                  color: AppColors.positive,
                  icon: Icons.trending_up_rounded,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniStat('PF', 'R\$ 22.100', AppColors.accent1),
              const SizedBox(height: 8),
              _MiniStat('PJ', 'R\$ 26.220', AppColors.accent3),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(label,
                style: AppTypo.labelSmall.copyWith(color: color)),
          ),
          const SizedBox(height: 2),
          Text(value,
              style: AppTypo.bodySmall.copyWith(
                  fontWeight: FontWeight.w600)),
        ],
      );
}

// ─── App icon (tile in the grid) ──────────────────────────────────────────────

class _AppIcon extends StatelessWidget {
  final AppTool tool;
  const _AppIcon({required this.tool});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(tool.route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconBadge(
              icon: tool.icon, color: tool.color, size: 60),
          const SizedBox(height: AppSpacing.sm - 2),
          Text(
            tool.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypo.labelSmall.copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dock ─────────────────────────────────────────────────────────────────────

class _Dock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.smd),
        radius: AppRadius.xxl,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dockTools
              .map((tool) => GestureDetector(
                    onTap: () => context.go(tool.route),
                    child: AppIconBadge(
                      icon: tool.icon,
                      color: tool.color,
                      size: 52,
                      iconSize: 24,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
