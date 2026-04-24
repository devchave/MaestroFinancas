import 'package:flutter/material.dart';
import '../models/finance.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_ui.dart';

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
  String? _accountId;
  String? _cardId; // null = pago direto pela conta
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  final _accountStore = AccountStore.instance;
  final _cardStore = CardStore.instance;

  List<TxCategory> get _cats =>
      _type == TxType.income ? incomeCategories : expenseCategories;

  List<Account> get _accounts => _accountStore.all;

  /// Cartões disponíveis para a conta selecionada.
  List<PaymentCard> get _availableCards {
    if (_accountId == null) return [];
    return _cardStore.forAccount(_accountId!);
  }

  @override
  void initState() {
    super.initState();
    if (_accounts.isNotEmpty) {
      _accountId = _accounts.first.id;
    }
  }

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty &&
      _category != null &&
      _accountId != null &&
      (double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0) > 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0 || _accountId == null) return;
    widget.store.add(Transaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      amount: amount,
      type: _type,
      category: _category!,
      date: _date,
      accountId: _accountId!,
      cardId: _type == TxType.expense ? _cardId : null,
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
        color: Color(0xFFF0F4FA),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.md,
            AppSpacing.screen,
            AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

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
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: _TypeBtn(
                    label: 'Receita',
                    icon: Icons.arrow_downward_rounded,
                    selected: _type == TxType.income,
                    color: AppColors.positive,
                    onTap: () => setState(() {
                      _type = TxType.income;
                      _category = null;
                      _cardId = null; // receita não vai em cartão
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Amount
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              autofocus: true,
              style: AppTypo.display.copyWith(fontSize: 36),
              decoration: InputDecoration(
                hintText: '0,00',
                hintStyle: AppTypo.display.copyWith(
                    fontSize: 36,
                    color: AppColors.textMuted.withValues(alpha: 0.4)),
                prefixText: 'R\$ ',
                prefixStyle: AppTypo.title
                    .copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const AppDivider(),
            const SizedBox(height: AppSpacing.md),

            // Description
            AppTextField(
              controller: _titleCtrl,
              label: 'Descrição',
              icon: Icons.edit_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),

            // Account selector
            Text('Conta', style: AppTypo.label),
            const SizedBox(height: AppSpacing.sm),
            if (_accounts.isEmpty)
              Text(
                'Nenhuma conta cadastrada. Vá em Contas primeiro.',
                style: AppTypo.bodySmall.copyWith(
                    color: AppColors.negative),
              )
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _accounts.map((a) {
                  return StatusChip(
                    label: a.name,
                    color: a.color,
                    icon: a.type.icon,
                    selected: _accountId == a.id,
                    onTap: () => setState(() {
                      _accountId = a.id;
                      _cardId = null; // reset ao trocar de conta
                    }),
                  );
                }).toList(),
              ),
            const SizedBox(height: AppSpacing.md),

            // Card selector (só em despesas)
            if (_type == TxType.expense && _availableCards.isNotEmpty) ...[
              Text('Cartão (opcional)', style: AppTypo.label),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  StatusChip(
                    label: 'Sem cartão',
                    color: AppColors.textMuted,
                    icon: Icons.payments_rounded,
                    selected: _cardId == null,
                    onTap: () => setState(() => _cardId = null),
                  ),
                  ..._availableCards.map((c) => StatusChip(
                        label: c.name,
                        color: AppColors.accent1,
                        icon: c.type.icon,
                        selected: _cardId == c.id,
                        onTap: () => setState(() => _cardId = c.id),
                      )),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Category
            Text('Categoria', style: AppTypo.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _cats.map((cat) {
                return StatusChip(
                  label: cat.label,
                  icon: cat.icon,
                  color: cat.color,
                  selected: _category == cat,
                  onTap: () => setState(() => _category = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Date picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.smd,
                    vertical: AppSpacing.smd + 1),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${_date.day.toString().padLeft(2, '0')}/'
                      '${_date.month.toString().padLeft(2, '0')}/'
                      '${_date.year}',
                      style: AppTypo.body,
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down_rounded,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            AppButton(
              label: 'Salvar lançamento',
              onPressed: _canSave ? _save : null,
              size: AppButtonSize.large,
              expand: true,
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd + 1),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.18)
              : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? color : AppColors.glassBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? color : AppColors.textSecondary, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypo.bodyLarge.copyWith(
                color: selected ? color : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
