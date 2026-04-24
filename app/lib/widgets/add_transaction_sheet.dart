import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';

void showAddTransactionSheet(BuildContext context, TransactionStore store) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddTransactionSheet(store: store),
  );
}

class AddTransactionSheet extends StatefulWidget {
  final TransactionStore store;
  const AddTransactionSheet({super.key, required this.store});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  TxType _type = TxType.expense;
  TxCategory? _category;
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String _account = 'PF';

  List<TxCategory> get _cats =>
      _type == TxType.income ? incomeCategories : expenseCategories;

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty &&
      _category != null &&
      (double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0) > 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;
    widget.store.add(Transaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      amount: amount,
      type: _type,
      category: _category!,
      date: _date,
      account: _account,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Type toggle
            Row(
              children: [
                Expanded(
                  child: _TypeBtn(
                    label: 'Despesa',
                    icon: Icons.arrow_upward_rounded,
                    selected: _type == TxType.expense,
                    color: AppColors.negative,
                    onTap: () => setState(() {
                      _type = TxType.expense;
                      _category = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeBtn(
                    label: 'Receita',
                    icon: Icons.arrow_downward_rounded,
                    selected: _type == TxType.income,
                    color: AppColors.positive,
                    onTap: () => setState(() {
                      _type = TxType.income;
                      _category = null;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              autofocus: true,
              style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                hintText: '0,00',
                hintStyle: GoogleFonts.inter(
                    color: AppColors.glassBorder,
                    fontSize: 36,
                    fontWeight: FontWeight.w800),
                prefixText: 'R\$ ',
                prefixStyle: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const Divider(color: AppColors.glassBorder, height: 1),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Descrição',
                labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.edit_rounded,
                    color: AppColors.textSecondary, size: 18),
                filled: true,
                fillColor: AppColors.glassWhite,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.glassBorder)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.glassBorder)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.accent1, width: 1.5)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Category
            Text('Categoria',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cats.map((cat) {
                final sel = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? cat.color.withValues(alpha: 0.22)
                          : AppColors.glassWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? cat.color : AppColors.glassBorder,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon,
                            color: sel ? cat.color : AppColors.textSecondary,
                            size: 15),
                        const SizedBox(width: 5),
                        Text(
                          cat.label,
                          style: GoogleFonts.inter(
                            color:
                                sel ? cat.color : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight:
                                sel ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Date + Account
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) =>
                            Theme(data: ThemeData.dark(), child: child!),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.glassWhite,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: AppColors.textSecondary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${_date.day.toString().padLeft(2, '0')}/'
                            '${_date.month.toString().padLeft(2, '0')}/'
                            '${_date.year}',
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ...['PF', 'PJ'].map((acc) {
                  final sel = _account == acc;
                  return GestureDetector(
                    onTap: () => setState(() => _account = acc),
                    child: Container(
                      margin: EdgeInsets.only(left: acc == 'PJ' ? 6 : 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 13),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.accent3.withValues(alpha: 0.22)
                            : AppColors.glassWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel
                              ? AppColors.accent3
                              : AppColors.glassBorder,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        acc,
                        style: GoogleFonts.inter(
                          color: sel
                              ? AppColors.accent2
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Save
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canSave ? AppColors.accent1 : AppColors.glassBorder,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _canSave ? _save : null,
                child: Text(
                  'Salvar lançamento',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color:
              selected ? color.withValues(alpha: 0.18) : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppColors.glassBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color:
                    selected ? color : AppColors.textSecondary,
                size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: selected ? color : AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
