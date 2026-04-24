import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../state/app_context.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/add_transaction_sheet.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/app_shell.dart';
import 'dashboard_screen.dart' show MonthSelector, TxRow;

enum TxFilter { all, income, expense }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late DateTime _month;
  TxFilter _filter = TxFilter.all;
  final _store = TransactionStore.instance;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  List<Transaction> _filtered(List<Transaction> all) => switch (_filter) {
        TxFilter.income =>
          all.where((t) => t.type == TxType.income).toList(),
        TxFilter.expense =>
          all.where((t) => t.type == TxType.expense).toList(),
        TxFilter.all => all,
      };

  Map<String, List<Transaction>> _grouped(List<Transaction> txs) {
    final map = <String, List<Transaction>>{};
    for (final t in txs) {
      (map[fmtDateGroup(t.date)] ??= []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showTopBar: true,
      currentId: 'transactions',
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent1,
        onPressed: () => showAddTransactionSheet(context, _store),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      content: ListenableBuilder(
        listenable: Listenable.merge([_store, AppContext.instance]),
        builder: (context, _) {
          final y = _month.year;
          final m = _month.month;
          // Aplica filtro de contexto global antes de calcular métricas
          final all = AppContext.instance
              .filterTransactions(_store.forMonth(y, m));
          final income = all
              .where((t) => t.type == TxType.income)
              .fold<double>(0, (s, t) => s + t.amount);
          final expense = all
              .where((t) => t.type == TxType.expense)
              .fold<double>(0, (s, t) => s + t.amount);
          final visible = _filtered(all);
          final groups = _grouped(visible);

          return Column(
            children: [
              // Resumo
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.sm,
                    AppSpacing.screen,
                    AppSpacing.smd),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                          label: 'Receitas',
                          value: income,
                          color: AppColors.positive,
                          icon: Icons.south_rounded),
                    ),
                    const SizedBox(width: AppSpacing.smd),
                    Expanded(
                      child: _SummaryTile(
                          label: 'Despesas',
                          value: expense,
                          color: AppColors.negative,
                          icon: Icons.north_rounded),
                    ),
                    const SizedBox(width: AppSpacing.smd),
                    Expanded(
                      child: _SummaryTile(
                          label: 'Saldo',
                          value: income - expense,
                          color: (income - expense) >= 0
                              ? AppColors.positive
                              : AppColors.negative,
                          icon: Icons.account_balance_wallet_rounded),
                    ),
                  ],
                ),
              ),

              // Filtros
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                child: Row(
                  children: [
                    _filterChip('Todos', TxFilter.all, all.length),
                    const SizedBox(width: AppSpacing.sm),
                    _filterChip(
                        'Receitas',
                        TxFilter.income,
                        all
                            .where((t) => t.type == TxType.income)
                            .length),
                    const SizedBox(width: AppSpacing.sm),
                    _filterChip(
                        'Despesas',
                        TxFilter.expense,
                        all
                            .where((t) => t.type == TxType.expense)
                            .length),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.smd),

              // Lista
              Expanded(
                child: visible.isEmpty
                    ? _EmptyList()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screen,
                            0,
                            AppSpacing.screen,
                            AppSpacing.hero + AppSpacing.xl),
                        children: [
                          for (final entry in groups.entries) ...[
                            _DateHeader(label: entry.key),
                            ...entry.value.map((t) => TxRow(
                                tx: t,
                                onDelete: () => _store.remove(t.id))),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, TxFilter value, int count) {
    return StatusChip(
      label: label,
      color: AppColors.accent1,
      selected: _filter == value,
      count: count,
      onTap: () => setState(() => _filter = value),
    );
  }
}

// ─── Summary tile ─────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd, vertical: AppSpacing.sm + 1),
      radius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 4),
              Text(label, style: AppTypo.labelSmall),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            fmtBRL(value.abs()),
            style: AppTypo.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Date header ──────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: AppSpacing.sm, top: AppSpacing.xs),
      child: Row(
        children: [
          Text(label, style: AppTypo.label),
          const SizedBox(width: AppSpacing.smd - 2),
          const Expanded(child: AppDivider()),
        ],
      ),
    );
  }
}

// ─── Empty ────────────────────────────────────────────────────────────────────

class _EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_rounded,
              color: AppColors.glassBorder, size: 40),
          const SizedBox(height: AppSpacing.smd),
          Text('Nenhuma transação encontrada',
              style: AppTypo.body
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
