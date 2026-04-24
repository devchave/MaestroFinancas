import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/transaction.dart';
import '../../theme/app_colors.dart';
import '../../widgets/add_transaction_sheet.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/tool_scaffold.dart';
import 'dashboard_screen.dart' show MonthSelector, TxRow;

enum _Filter { all, income, expense }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late DateTime _month;
  _Filter _filter = _Filter.all;
  final _store = TransactionStore.instance;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  List<Transaction> _filtered(List<Transaction> all) => switch (_filter) {
        _Filter.income => all.where((t) => t.type == TxType.income).toList(),
        _Filter.expense => all.where((t) => t.type == TxType.expense).toList(),
        _Filter.all => all,
      };

  Map<String, List<Transaction>> _grouped(List<Transaction> txs) {
    final map = <String, List<Transaction>>{};
    for (final t in txs) {
      final key = fmtDateGroup(t.date);
      (map[key] ??= []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      toolId: 'transactions',
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
        listenable: _store,
        builder: (context, _) {
          final y = _month.year;
          final m = _month.month;
          final all = _store.forMonth(y, m);
          final income = _store.incomeForMonth(y, m);
          final expense = _store.expenseForMonth(y, m);
          final visible = _filtered(all);
          final groups = _grouped(visible);

          return Column(
            children: [
              // Mini summary
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    _SummaryChip(
                        label: 'Receitas',
                        value: income,
                        color: AppColors.positive,
                        icon: Icons.south_rounded),
                    const SizedBox(width: 10),
                    _SummaryChip(
                        label: 'Despesas',
                        value: expense,
                        color: AppColors.negative,
                        icon: Icons.north_rounded),
                    const SizedBox(width: 10),
                    _SummaryChip(
                        label: 'Saldo',
                        value: income - expense,
                        color: (income - expense) >= 0
                            ? AppColors.positive
                            : AppColors.negative,
                        icon: Icons.account_balance_wallet_rounded),
                  ],
                ),
              ),

              // Filter tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _FilterTab('Todos', _Filter.all, all.length),
                    const SizedBox(width: 8),
                    _FilterTab('Receitas', _Filter.income,
                        all.where((t) => t.type == TxType.income).length),
                    const SizedBox(width: 8),
                    _FilterTab('Despesas', _Filter.expense,
                        all.where((t) => t.type == TxType.expense).length),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // List
              Expanded(
                child: visible.isEmpty
                    ? _EmptyList()
                    : ListView(
                        padding:
                            const EdgeInsets.fromLTRB(20, 0, 20, 100),
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

  Widget _FilterTab(String label, _Filter value, int count) {
    final sel = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel
              ? AppColors.accent1.withValues(alpha: 0.18)
              : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? AppColors.accent1 : AppColors.glassBorder,
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: sel ? AppColors.accent1 : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: sel
                    ? AppColors.accent1.withValues(alpha: 0.2)
                    : AppColors.glassBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: GoogleFonts.inter(
                    color: sel ? AppColors.accent1 : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        borderRadius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 12),
                const SizedBox(width: 4),
                Text(label,
                    style: GoogleFonts.inter(
                        color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              fmtBRL(value.abs()),
              style: GoogleFonts.inter(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          const Expanded(
              child: Divider(color: AppColors.glassBorder, height: 1)),
        ],
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_rounded,
              color: AppColors.glassBorder, size: 40),
          const SizedBox(height: 12),
          Text('Nenhuma transação encontrada',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
