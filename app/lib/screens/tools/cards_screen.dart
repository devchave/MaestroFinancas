import 'package:flutter/material.dart';
import '../../models/finance.dart';
import '../../models/transaction.dart';
import '../../state/app_context.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_ui.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final _store = CardStore.instance;
  final _accountStore = AccountStore.instance;
  final _txStore = TransactionStore.instance;

  /// Fatura atual = despesas do mês corrente no cartão.
  double _invoiceFor(String cardId) {
    final now = DateTime.now();
    return _txStore.all
        .where((t) =>
            t.cardId == cardId &&
            t.type == TxType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold<double>(0, (s, t) => s + t.amount);
  }

  void _openForm([PaymentCard? card]) {
    if (_accountStore.all.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre uma conta antes de adicionar cartões.'),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CardFormSheet(
        store: _store,
        accounts: _accountStore.all,
        initial: card,
      ),
    );
  }

  void _confirmDelete(PaymentCard c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg1,
        title: Text('Remover cartão?', style: AppTypo.title),
        content: Text(
          'Tem certeza que deseja remover "${c.name}"?',
          style: AppTypo.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.negative),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed == true) _store.remove(c.id);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showTopBar: true,
      currentId: 'cards',
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent1,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Novo cartão',
            style: AppTypo.body.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      content: ListenableBuilder(
        listenable: Listenable.merge(
            [_store, _accountStore, _txStore, AppContext.instance]),
        builder: (context, _) {
          // Filtra cartões cujas contas estão no contexto atual
          final cards = _store.all.where((c) {
            final acc = _accountStore.byId(c.accountId);
            return acc != null && AppContext.instance.matchesAccount(acc);
          }).toList();
          if (cards.isEmpty) {
            return _EmptyState(onAdd: () => _openForm());
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                AppSpacing.hero + AppSpacing.xl),
            itemCount: cards.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final c = cards[i];
              final invoice = _invoiceFor(c.id);
              final account = _accountStore.byId(c.accountId);
              return _CardTile(
                card: c,
                account: account,
                invoice: invoice,
                onTap: () => _openForm(c),
                onDelete: () => _confirmDelete(c),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Card tile (visual de cartão) ─────────────────────────────────────────────

class _CardTile extends StatelessWidget {
  final PaymentCard card;
  final Account? account;
  final double invoice;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CardTile({
    required this.card,
    required this.account,
    required this.invoice,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accountColor = account?.color ?? AppColors.accent3;
    final limit = card.limit;
    final usedPct = limit > 0 ? (invoice / limit).clamp(0.0, 1.0) : 0.0;
    final overLimit = limit > 0 && invoice > limit;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accountColor,
              Color.alphaBlend(
                Colors.black.withValues(alpha: 0.25),
                accountColor,
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: accountColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Rim no topo (glass polish)
            Positioned(
              top: 0, left: AppSpacing.md, right: AppSpacing.md,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.6),
                    Colors.white.withValues(alpha: 0),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(card.type.icon, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(card.name,
                            style: AppTypo.titleSmall
                                .copyWith(color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 20),
                        onPressed: onDelete,
                        tooltip: 'Remover',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Bandeira / tipo
                  Wrap(
                    spacing: 8,
                    children: [
                      _WhitePill(label: card.brand.label),
                      _WhitePill(label: card.type.label),
                      if (account != null)
                        _WhitePill(
                            label: 'Conta: ${account!.name}',
                            icon: Icons.account_balance_rounded),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fatura atual',
                                style: AppTypo.labelSmall.copyWith(
                                    color: Colors.white
                                        .withValues(alpha: 0.75))),
                            const SizedBox(height: 2),
                            Text(fmtBRL(invoice),
                                style: AppTypo.numberLarge.copyWith(
                                    color: Colors.white, fontSize: 24)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Limite',
                              style: AppTypo.labelSmall.copyWith(
                                  color: Colors.white
                                      .withValues(alpha: 0.75))),
                          const SizedBox(height: 2),
                          Text(fmtBRL(limit),
                              style: AppTypo.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  if (limit > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: usedPct,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(
                          overLimit
                              ? AppColors.negative
                              : Colors.white,
                        ),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(usedPct * 100).toStringAsFixed(0)}% usado'
                      '${overLimit ? ' — limite estourado' : ''}',
                      style: AppTypo.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.75)),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(Icons.lock_clock_rounded,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.75)),
                      const SizedBox(width: 3),
                      Text('fecha dia ${card.closingDay}',
                          style: AppTypo.caption.copyWith(
                              color:
                                  Colors.white.withValues(alpha: 0.75))),
                      const SizedBox(width: AppSpacing.smd),
                      Icon(Icons.event_rounded,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.75)),
                      const SizedBox(width: 3),
                      Text('vence dia ${card.dueDay}',
                          style: AppTypo.caption.copyWith(
                              color:
                                  Colors.white.withValues(alpha: 0.75))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhitePill extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _WhitePill({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 11),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: AppTypo.labelSmall
                  .copyWith(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.credit_card_rounded,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text('Nenhum cartão cadastrado',
                style: AppTypo.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Cadastre seus cartões de crédito e débito para\n'
              'acompanhar fatura, limite e próximos vencimentos.',
              style: AppTypo.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Cadastrar primeiro cartão',
              icon: Icons.add_rounded,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Form sheet
// ════════════════════════════════════════════════════════════════════════════

class _CardFormSheet extends StatefulWidget {
  final CardStore store;
  final List<Account> accounts;
  final PaymentCard? initial;

  const _CardFormSheet({
    required this.store,
    required this.accounts,
    this.initial,
  });

  @override
  State<_CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends State<_CardFormSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _limitCtrl;
  late String _accountId;
  late CardBrand _brand;
  late CardType _type;
  late int _closingDay;
  late int _dueDay;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _limitCtrl = TextEditingController(
        text: c?.limit.toStringAsFixed(2).replaceAll('.', ',') ?? '');
    _accountId = c?.accountId ?? widget.accounts.first.id;
    _brand = c?.brand ?? CardBrand.mastercard;
    _type = c?.type ?? CardType.credit;
    _closingDay = c?.closingDay ?? 1;
    _dueDay = c?.dueDay ?? 10;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  void _save() {
    final isEdit = widget.initial != null;
    final limit =
        double.tryParse(_limitCtrl.text.replaceAll(',', '.')) ?? 0;
    final c = PaymentCard(
      id: widget.initial?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      accountId: _accountId,
      brand: _brand,
      type: _type,
      limit: limit,
      closingDay: _closingDay,
      dueDay: _dueDay,
    );
    if (isEdit) {
      widget.store.update(c);
    } else {
      widget.store.add(c);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.initial != null;

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
            Text(isEdit ? 'Editar cartão' : 'Novo cartão',
                style: AppTypo.headline),
            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              controller: _nameCtrl,
              label: 'Nome do cartão',
              icon: Icons.credit_card_rounded,
              autofocus: !isEdit,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.smd),
            AppTextField(
              controller: _limitCtrl,
              label: 'Limite',
              icon: Icons.speed_rounded,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Conta vinculada', style: AppTypo.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: widget.accounts.map((a) {
                return StatusChip(
                  label: a.name,
                  color: a.color,
                  icon: a.type.icon,
                  selected: _accountId == a.id,
                  onTap: () => setState(() => _accountId = a.id),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Bandeira', style: AppTypo.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: CardBrand.values.map((b) {
                return StatusChip(
                  label: b.label,
                  color: AppColors.accent1,
                  selected: _brand == b,
                  onTap: () => setState(() => _brand = b),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Tipo', style: AppTypo.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: CardType.values.map((t) {
                return StatusChip(
                  label: t.label,
                  color: AppColors.accent3,
                  icon: t.icon,
                  selected: _type == t,
                  onTap: () => setState(() => _type = t),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _DayPicker(
                    label: 'Fecha dia',
                    value: _closingDay,
                    onChanged: (v) => setState(() => _closingDay = v),
                  ),
                ),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: _DayPicker(
                    label: 'Vence dia',
                    value: _dueDay,
                    onChanged: (v) => setState(() => _dueDay = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            AppButton(
              label: isEdit ? 'Salvar alterações' : 'Cadastrar cartão',
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

class _DayPicker extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _DayPicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypo.label),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.smd, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded, size: 18),
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              Expanded(
                child: Text('$value',
                    textAlign: TextAlign.center,
                    style: AppTypo.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700)),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 18),
                onPressed: value < 31 ? () => onChanged(value + 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
