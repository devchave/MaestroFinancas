import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/transaction.dart';
import '../../state/app_context.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/add_transaction_sheet.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/charts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _month;
  final _store = TransactionStore.instance;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showTopBar: true,
      currentId: 'dashboard',
      trailing: MonthSelector(
        month: _month,
        onPrev: () =>
            setState(() => _month = DateTime(_month.year, _month.month - 1)),
        onNext: () {
          final now = DateTime.now();
          if (_month.year == now.year && _month.month == now.month) return;
          setState(
              () => _month = DateTime(_month.year, _month.month + 1));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent1,
        onPressed: () => showAddTransactionSheet(context, _store),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Novo lançamento',
            style: AppTypo.body
                .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      content: ListenableBuilder(
        listenable: Listenable.merge([_store, AppContext.instance]),
        builder: (context, _) {
          final y = _month.year;
          final m = _month.month;
          final ctx = AppContext.instance;

          final allMonth =
              ctx.filterTransactions(_store.forMonth(y, m));
          final income = allMonth
              .where((t) => t.type == TxType.income)
              .fold(0.0, (s, t) => s + t.amount);
          final expense = allMonth
              .where((t) => t.type == TxType.expense)
              .fold(0.0, (s, t) => s + t.amount);
          final balance = income - expense;

          final expCats = <TxCategory, double>{};
          final incCats = <TxCategory, double>{};
          for (final t in allMonth) {
            if (t.type == TxType.expense) {
              expCats[t.category] = (expCats[t.category] ?? 0) + t.amount;
            } else {
              incCats[t.category] = (incCats[t.category] ?? 0) + t.amount;
            }
          }
          final sortedExp = expCats.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final sortedInc = incCats.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // 6-month series filtered by context
          final series = _store.monthlySeries(
            lastMonths: 6,
            filter: ctx.matchesTransaction,
          );
          final incSpark = series.map((s) => s.income).toList();
          final expSpark = series.map((s) => s.expense).toList();

          final recent = allMonth.take(5).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.smd,
                AppSpacing.screen,
                AppSpacing.hero + AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Saldo principal ─────────────────────────────────────
                _BalanceHero(balance: balance),
                const SizedBox(height: AppSpacing.smd),

                // ── 2. Receitas / Despesas com sparkline ───────────────────
                Row(
                  children: [
                    Expanded(
                      child: _FlowCard(
                        label: 'Receitas',
                        value: income,
                        color: AppColors.positive,
                        icon: Icons.south_rounded,
                        sparkData: incSpark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.smd),
                    Expanded(
                      child: _FlowCard(
                        label: 'Despesas',
                        value: expense,
                        color: AppColors.negative,
                        icon: Icons.north_rounded,
                        sparkData: expSpark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── 3. Evolução mensal (6 meses) ───────────────────────────
                const SectionLabel('EVOLUÇÃO MENSAL'),
                const SizedBox(height: AppSpacing.smd),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: MonthlyGroupedBarChart(series: series, height: 140),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── 4. Top despesas por categoria (donut + legenda) ────────
                if (sortedExp.isNotEmpty) ...[
                  const SectionLabel('TOP DESPESAS'),
                  const SizedBox(height: AppSpacing.smd),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: _DonutSection(
                      entries: sortedExp.take(5).toList(),
                      total: expense,
                      label: 'Despesas',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // ── 5. Top entradas por categoria (barras horizontais) ─────
                if (sortedInc.isNotEmpty) ...[
                  const SectionLabel('TOP ENTRADAS'),
                  const SizedBox(height: AppSpacing.smd),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: HorizontalBarList(
                      items: sortedInc.take(5).map((e) => HBarItem(
                            label: e.key.label,
                            value: e.value,
                            color: e.key.color,
                            icon: e.key.icon,
                          )).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // ── 6. Últimas transações ──────────────────────────────────
                SectionLabel(
                  'ÚLTIMAS TRANSAÇÕES',
                  trailing: TextButton(
                    onPressed: () => context.go('/app/transactions'),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text('Ver todas →',
                        style: AppTypo.bodySmall
                            .copyWith(color: AppColors.accent1)),
                  ),
                ),
                const SizedBox(height: AppSpacing.smd),
                if (recent.isEmpty)
                  _EmptyState()
                else
                  ...recent.map((t) =>
                      TxRow(tx: t, onDelete: () => _store.remove(t.id))),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Balance hero card ────────────────────────────────────────────────────────

class _BalanceHero extends StatelessWidget {
  final double balance;
  const _BalanceHero({required this.balance});

  @override
  Widget build(BuildContext context) {
    final positive = balance >= 0;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Saldo do mês', style: AppTypo.bodySmall),
              const Spacer(),
              _ContextBadge(),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtBRL(balance),
                style: AppTypo.numberLarge.copyWith(
                  color: positive ? AppColors.positive : AppColors.negative,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  positive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: positive ? AppColors.positive : AppColors.negative,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContextBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctx = AppContext.instance;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ctx.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: ctx.color.withValues(alpha: 0.35)),
      ),
      child: Text(ctx.label,
          style: AppTypo.labelSmall.copyWith(color: ctx.color)),
    );
  }
}

// ─── Flow card (receitas / despesas) com sparkline ────────────────────────────

class _FlowCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  final List<double> sparkData;

  const _FlowCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.sparkData,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.smd),
      radius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 13),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: AppTypo.labelSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            fmtBRL(value),
            style: AppTypo.bodyLarge.copyWith(
                color: color, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          SparklineChart(data: sparkData, color: color, height: 38),
        ],
      ),
    );
  }
}

// ─── Donut section ────────────────────────────────────────────────────────────

class _DonutSection extends StatelessWidget {
  final List<MapEntry<TxCategory, double>> entries;
  final double total;
  final String label;

  const _DonutSection({
    required this.entries,
    required this.total,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final segments = entries
        .map((e) => DonutSegment(
            color: e.key.color, value: e.value, label: e.key.label))
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Donut
        DonutChart(
          segments: segments,
          size: 120,
          strokeWidth: 18,
          centerLabel: label,
          centerSub: fmtBRL(total)
              .replaceAll('R\$ ', '')
              .replaceAll(',00', ''),
        ),
        const SizedBox(width: AppSpacing.md),
        // Legend
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: entries.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final pct = total > 0 ? (e.value / total * 100) : 0.0;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < entries.length - 1 ? AppSpacing.sm : 0),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: e.key.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(e.key.label,
                          style: AppTypo.caption,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text('${pct.toStringAsFixed(0)}%',
                        style: AppTypo.caption.copyWith(
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Month selector ───────────────────────────────────────────────────────────

class MonthSelector extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const MonthSelector({
    super.key,
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrent =
        month.year == now.year && month.month == now.month;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
        Text(fmtMonth(month), style: AppTypo.bodyLarge),
        _NavBtn(
          icon: Icons.chevron_right_rounded,
          onTap: onNext,
          dimmed: isCurrent,
        ),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool dimmed;
  const _NavBtn(
      {required this.icon, required this.onTap, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Icon(icon,
            color: dimmed
                ? AppColors.glassBorder
                : AppColors.textSecondary,
            size: 22),
      ),
    );
  }
}

// ─── TxRow (shared with transactions_screen) ──────────────────────────────────

class TxRow extends StatelessWidget {
  final Transaction tx;
  final VoidCallback onDelete;

  const TxRow({super.key, required this.tx, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TxType.income;
    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding:
            const EdgeInsets.only(right: AppSpacing.screen),
        decoration: BoxDecoration(
          color: AppColors.negative.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.negative),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smd + 2, vertical: AppSpacing.smd),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tx.category.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child:
                  Icon(tx.category.icon, color: tx.category.color, size: 18),
            ),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title,
                      style:
                          AppTypo.body.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(tx.category.label, style: AppTypo.caption),
                      const SizedBox(width: 6),
                      _AccountTag(tx.kind),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${fmtBRL(tx.amount)}',
                  style: AppTypo.body.copyWith(
                    color: isIncome
                        ? AppColors.positive
                        : AppColors.negative,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(fmtDateShort(tx.date), style: AppTypo.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTag extends StatelessWidget {
  final String account;
  const _AccountTag(this.account);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.accent3.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(account,
          style: AppTypo.labelSmall.copyWith(color: AppColors.accent2)),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded,
                color: AppColors.glassBorder, size: 40),
            const SizedBox(height: AppSpacing.smd),
            Text('Nenhuma transação neste mês',
                style: AppTypo.body
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('Toque em "Novo lançamento" para começar',
                style: AppTypo.caption),
          ],
        ),
      ),
    );
  }
}
