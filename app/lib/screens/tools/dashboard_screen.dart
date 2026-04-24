import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/transaction.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/add_transaction_sheet.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/tool_scaffold.dart';

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
    return ToolScaffold(
      toolId: 'dashboard',
      trailing: MonthSelector(
        month: _month,
        onPrev: () => setState(
            () => _month = DateTime(_month.year, _month.month - 1)),
        onNext: () {
          final now = DateTime.now();
          if (_month.year == now.year && _month.month == now.month) return;
          setState(() => _month = DateTime(_month.year, _month.month + 1));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent1,
        onPressed: () => showAddTransactionSheet(context, _store),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Novo lançamento',
            style: AppTypo.body.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      content: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final y = _month.year;
          final m = _month.month;
          final income = _store.incomeForMonth(y, m);
          final expense = _store.expenseForMonth(y, m);
          final balance = income - expense;
          final cats = _store.expensesByCategory(y, m);
          final recent = _store.forMonth(y, m).take(5).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.smd,
                AppSpacing.screen,
                AppSpacing.hero + AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BalanceCard(
                    balance: balance, income: income, expense: expense),
                const SizedBox(height: AppSpacing.md),
                _IncomeExpenseBar(income: income, expense: expense),
                const SizedBox(height: AppSpacing.lg),
                if (cats.isNotEmpty) ...[
                  const SectionLabel('GASTOS POR CATEGORIA'),
                  const SizedBox(height: AppSpacing.smd),
                  _CategoriesCard(categories: cats, total: expense),
                  const SizedBox(height: AppSpacing.lg),
                ],
                SectionLabel(
                  'ÚLTIMAS TRANSAÇÕES',
                  trailing: TextButton(
                    onPressed: () => context.go('/app/transactions'),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap),
                    child: Text('Ver todas →',
                        style: AppTypo.bodySmall
                            .copyWith(color: AppColors.accent1)),
                  ),
                ),
                const SizedBox(height: AppSpacing.smd),
                if (recent.isEmpty)
                  _EmptyState()
                else
                  ...recent.map((t) => TxRow(
                      tx: t,
                      onDelete: () => _store.remove(t.id))),
              ],
            ),
          );
        },
      ),
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
    final isCurrent = month.year == now.year && month.month == now.month;
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
  const _NavBtn({required this.icon, required this.onTap, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Icon(icon,
            color: dimmed ? AppColors.glassBorder : AppColors.textSecondary,
            size: 22),
      ),
    );
  }
}

// ─── Balance card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const _BalanceCard(
      {required this.balance,
      required this.income,
      required this.expense});

  @override
  Widget build(BuildContext context) {
    final positive = balance >= 0;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo do mês', style: AppTypo.bodySmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                fmtBRL(balance),
                style: AppTypo.numberLarge.copyWith(
                  color: positive ? AppColors.positive : AppColors.negative,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                positive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: positive ? AppColors.positive : AppColors.negative,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniTile(
                  label: 'Receitas',
                  value: income,
                  color: AppColors.positive,
                  icon: Icons.south_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: _MiniTile(
                  label: 'Despesas',
                  value: expense,
                  color: AppColors.negative,
                  icon: Icons.north_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _MiniTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypo.caption),
                Text(
                  fmtBRL(value),
                  style: AppTypo.bodySmall.copyWith(
                      color: color, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Income vs expense bar ────────────────────────────────────────────────────

class _IncomeExpenseBar extends StatelessWidget {
  final double income;
  final double expense;

  const _IncomeExpenseBar({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    if (total == 0) return const SizedBox.shrink();
    final incomeRatio = (income / total).clamp(0.01, 0.99);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Receitas vs Despesas', style: AppTypo.label),
              Text(
                '${(incomeRatio * 100).round()}% / '
                '${((1 - incomeRatio) * 100).round()}%',
                style: AppTypo.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: Row(
              children: [
                Expanded(
                  flex: (incomeRatio * 100).round(),
                  child: Container(height: 8, color: AppColors.positive),
                ),
                Expanded(
                  flex: ((1 - incomeRatio) * 100).round(),
                  child: Container(height: 8, color: AppColors.negative),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _Dot(color: AppColors.positive),
              const SizedBox(width: 4),
              Text('Receitas', style: AppTypo.caption),
              const SizedBox(width: AppSpacing.smd + 2),
              _Dot(color: AppColors.negative),
              const SizedBox(width: 4),
              Text('Despesas', style: AppTypo.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ─── Categories breakdown ─────────────────────────────────────────────────────

class _CategoriesCard extends StatelessWidget {
  final Map<TxCategory, double> categories;
  final double total;

  const _CategoriesCard({required this.categories, required this.total});

  @override
  Widget build(BuildContext context) {
    final top = categories.entries.take(5).toList();
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: top.asMap().entries.map((entry) {
          final e = entry.value;
          final pct = total > 0 ? e.value / total : 0.0;
          final isLast = entry.key == top.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.smd + 2),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: e.key.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(e.key.icon, color: e.key.color, size: 16),
                    ),
                    const SizedBox(width: AppSpacing.smd - 2),
                    Expanded(
                      child: Text(e.key.label,
                          style: AppTypo.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                    Text('${(pct * 100).toStringAsFixed(1)}%',
                        style: AppTypo.caption),
                    const SizedBox(width: AppSpacing.sm),
                    Text(fmtBRL(e.value),
                        style: AppTypo.bodySmall.copyWith(
                            color: AppColors.negative,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: e.key.color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(e.key.color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── TxRow (shared) ───────────────────────────────────────────────────────────

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
        padding: const EdgeInsets.only(right: AppSpacing.screen),
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
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
              color: AppColors.glassBorder.withValues(alpha: 0.5)),
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
              child: Icon(tx.category.icon,
                  color: tx.category.color, size: 18),
            ),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title,
                      style: AppTypo.body.copyWith(
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(tx.category.label, style: AppTypo.caption),
                      const SizedBox(width: 6),
                      _AccountTag(tx.account),
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
