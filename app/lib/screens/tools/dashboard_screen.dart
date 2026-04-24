import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/transaction.dart';
import '../../theme/app_colors.dart';
import '../../widgets/add_transaction_sheet.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/glass_container.dart';

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
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: AnimatedBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _store,
            builder: (context, _) {
              final y = _month.year;
              final m = _month.month;
              final income = _store.incomeForMonth(y, m);
              final expense = _store.expenseForMonth(y, m);
              final balance = income - expense;
              final cats = _store.expensesByCategory(y, m);
              final recent = _store.forMonth(y, m).take(5).toList();

              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _BalanceCard(
                              balance: balance,
                              income: income,
                              expense: expense),
                          const SizedBox(height: 16),
                          _IncomeExpenseBar(
                              income: income, expense: expense),
                          const SizedBox(height: 20),
                          if (cats.isNotEmpty) ...[
                            _sectionLabel('Gastos por categoria'),
                            const SizedBox(height: 10),
                            _CategoriesCard(
                                categories: cats, total: expense),
                            const SizedBox(height: 20),
                          ],
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _sectionLabel('Últimas transações'),
                              TextButton(
                                onPressed: () =>
                                    context.go('/tools/transactions'),
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap),
                                child: Text('Ver todas →',
                                    style: GoogleFonts.inter(
                                        color: AppColors.accent1,
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (recent.isEmpty)
                            _EmptyState()
                          else
                            ...recent.map((t) => TxRow(
                                tx: t,
                                onDelete: () => _store.remove(t.id))),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent1,
        onPressed: () => showAddTransactionSheet(context, _store),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Novo lançamento',
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textSecondary, size: 20),
            onPressed: () => context.go('/home'),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.bar_chart_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Visão Geral',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
          ),
          MonthSelector(
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
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3),
      );
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
        Text(
          fmtMonth(month),
          style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo do mês',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                fmtBRL(balance),
                style: GoogleFonts.inter(
                  color: positive ? AppColors.positive : AppColors.negative,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                positive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: positive ? AppColors.positive : AppColors.negative,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              const SizedBox(width: 12),
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

  const _MiniTile(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        color: AppColors.textSecondary, fontSize: 11)),
                Text(
                  fmtBRL(value),
                  style: GoogleFonts.inter(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
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

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Receitas vs Despesas',
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Text(
                '${(incomeRatio * 100).round()}% / '
                '${((1 - incomeRatio) * 100).round()}%',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Expanded(
                  flex: (incomeRatio * 100).round(),
                  child: Container(
                      height: 8, color: AppColors.positive),
                ),
                Expanded(
                  flex: ((1 - incomeRatio) * 100).round(),
                  child: Container(
                      height: 8, color: AppColors.negative),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Dot(color: AppColors.positive),
              const SizedBox(width: 4),
              Text('Receitas',
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(width: 14),
              _Dot(color: AppColors.negative),
              const SizedBox(width: 4),
              Text('Despesas',
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 11)),
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
        decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ─── Categories breakdown ─────────────────────────────────────────────────────

class _CategoriesCard extends StatelessWidget {
  final Map<TxCategory, double> categories;
  final double total;

  const _CategoriesCard(
      {required this.categories, required this.total});

  @override
  Widget build(BuildContext context) {
    final top = categories.entries.take(5).toList();
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: top.asMap().entries.map((entry) {
          final e = entry.value;
          final pct = total > 0 ? e.value / total : 0.0;
          final isLast = entry.key == top.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: e.key.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(e.key.icon,
                          color: e.key.color, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e.key.label,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                    Text(
                      '${(pct * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fmtBRL(e.value),
                      style: GoogleFonts.inter(
                          color: AppColors.negative,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor:
                        e.key.color.withValues(alpha: 0.1),
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
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.negative.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.negative),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(tx.category.icon,
                  color: tx.category.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(tx.category.label,
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 11)),
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
                  style: GoogleFonts.inter(
                    color: isIncome
                        ? AppColors.positive
                        : AppColors.negative,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fmtDateShort(tx.date),
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
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
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(account,
          style: GoogleFonts.inter(
              color: AppColors.accent2,
              fontSize: 10,
              fontWeight: FontWeight.w700)),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded,
                color: AppColors.glassBorder, size: 40),
            const SizedBox(height: 12),
            Text('Nenhuma transação neste mês',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Toque em "Novo lançamento" para começar',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
