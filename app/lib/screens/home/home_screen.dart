import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../models/app_tool.dart';
import '../../models/transaction.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = TransactionStore.instance;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentId: 'home',
      content: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final now = DateTime.now();
          final income = _store.incomeForMonth(now.year, now.month);
          final expense = _store.expenseForMonth(now.year, now.month);
          final savings = income - expense;
          final cats = _store.expensesByCategory(now.year, now.month);
          final topCat = cats.entries.isNotEmpty ? cats.entries.first : null;

          return Column(
            children: [
              const SizedBox(height: AppSpacing.smd),
              _GreetingBar().animate().fadeIn(delay: 200.ms),

              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screen,
                    AppSpacing.md, AppSpacing.screen, 0),
                child: _BalanceCard(savings: savings)
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.2, end: 0),
              ),
              const SizedBox(height: AppSpacing.smd),

              // Métricas do mês
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen),
                child: _MonthStatsRow(
                  income: income,
                  expense: expense,
                  savings: savings,
                  topCat: topCat,
                ).animate().fadeIn(delay: 400.ms),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Grid de apps — scroll vertical contínuo
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.sm),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: appTools.length,
                  itemBuilder: (context, i) {
                    final tool = appTools[i];
                    return _AppIcon(tool: tool)
                        .animate()
                        .fadeIn(
                            delay:
                                Duration(milliseconds: 80 + i * 40))
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          delay:
                              Duration(milliseconds: 80 + i * 40),
                          duration: 280.ms,
                          curve: Curves.easeOutBack,
                        );
                  },
                ),
              ),
            ],
          );
        },
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
                    Text('Olá, devchave', style: AppTypo.bodySmall),
                    const SizedBox(width: 6),
                    Icon(
                      AppColors.isNight
                          ? Icons.nights_stay_rounded
                          : Icons.wb_sunny_rounded,
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
              backgroundColor: AppColors.accent3,
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

// ─── Balance card (patrimônio total + PF/PJ) ─────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final double savings;
  const _BalanceCard({required this.savings});

  @override
  Widget build(BuildContext context) {
    // Mock: patrimônio cresce/descresce conforme savings do mês
    const patrimonio = 48320.0;
    const pf = 22100.0;
    const pj = 26220.0;
    final positive = savings >= 0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.xl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patrimônio total', style: AppTypo.bodySmall),
                const SizedBox(height: 2),
                Text(fmtBRL(patrimonio), style: AppTypo.numberLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      positive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: positive
                          ? AppColors.positive
                          : AppColors.negative,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${positive ? '+' : ''}${fmtBRL(savings)} este mês',
                      style: AppTypo.bodySmall.copyWith(
                        color: positive
                            ? AppColors.positive
                            : AppColors.negative,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _AccountTile('PF', pf, AppColors.accent1),
              const SizedBox(height: 6),
              _AccountTile('PJ', pj, AppColors.accent3),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _AccountTile(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(label,
              style: AppTypo.labelSmall.copyWith(color: color)),
        ),
        const SizedBox(height: 2),
        Text(fmtBRL(value),
            style: AppTypo.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

// ─── Month stats row (4 mini-cards) ──────────────────────────────────────────

class _MonthStatsRow extends StatelessWidget {
  final double income;
  final double expense;
  final double savings;
  final MapEntry<TxCategory, double>? topCat;

  const _MonthStatsRow({
    required this.income,
    required this.expense,
    required this.savings,
    required this.topCat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Receitas',
            value: fmtBRL(income),
            icon: Icons.south_rounded,
            color: AppColors.positive,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'Despesas',
            value: fmtBRL(expense),
            icon: Icons.north_rounded,
            color: AppColors.negative,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'Economia',
            value: fmtBRL(savings.abs()),
            icon: savings >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: savings >= 0 ? AppColors.accent4 : AppColors.negative,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: topCat != null
              ? _StatTile(
                  label: 'Maior gasto',
                  value: topCat!.key.label,
                  icon: topCat!.key.icon,
                  color: topCat!.key.color,
                  subtitle: fmtBRL(topCat!.value),
                )
              : _StatTile(
                  label: 'Maior gasto',
                  value: '—',
                  icon: Icons.remove_rounded,
                  color: AppColors.textMuted,
                ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd - 2, vertical: AppSpacing.smd - 2),
      radius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 3),
              Expanded(
                child: Text(label,
                    style: AppTypo.labelSmall,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTypo.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTypo.caption.copyWith(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

// ─── App icon tile ───────────────────────────────────────────────────────────

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
          AppIconBadge(icon: tool.icon, color: tool.color, size: 58),
          const SizedBox(height: 6),
          Text(
            tool.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypo.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
