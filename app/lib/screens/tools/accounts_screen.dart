import 'package:flutter/material.dart';
import '../../models/finance.dart';
import '../../models/transaction.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_ui.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final _store = AccountStore.instance;
  final _companyStore = CompanyStore.instance;
  final _txStore = TransactionStore.instance;

  double _currentBalance(Account a) =>
      a.initialBalance + _txStore.netFlowForAccount(a.id);

  void _openForm([Account? account]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AccountFormSheet(
        store: _store,
        companies: _companyStore.all,
        initial: account,
      ),
    );
  }

  void _confirmDelete(Account a) async {
    final txCount = _txStore.all.where((t) => t.accountId == a.id).length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg1,
        title: Text('Remover conta?', style: AppTypo.title),
        content: Text(
          txCount > 0
              ? 'Esta conta possui $txCount transação(ões) vinculadas. '
                  'Elas ficarão órfãs ao remover.\n\n'
                  'Tem certeza?'
              : 'Tem certeza que deseja remover "${a.name}"?',
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
    if (confirmed == true) _store.remove(a.id);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showTopBar: true,
      currentId: 'accounts',
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent1,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Nova conta',
            style: AppTypo.body.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      content: ListenableBuilder(
        listenable:
            Listenable.merge([_store, _companyStore, _txStore]),
        builder: (context, _) {
          final all = _store.all;
          if (all.isEmpty) {
            return _EmptyState(onAdd: () => _openForm());
          }

          // Agrupar: PF primeiro, depois por company
          final pfAccounts = all.where((a) => a.isPF).toList();
          final companies = _companyStore.all;
          final totalPF = pfAccounts.fold<double>(
              0, (s, a) => s + _currentBalance(a));

          final sections = <Widget>[
            _SummaryCard(
              totalPF: totalPF,
              totalPJ: _computeTotalPJ(all),
            ),
            const SizedBox(height: AppSpacing.md),
          ];

          if (pfAccounts.isNotEmpty) {
            sections.add(const _GroupHeader(
              icon: Icons.person_rounded,
              label: 'Pessoa física',
            ));
            sections.addAll(pfAccounts.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AccountTile(
                    account: a,
                    balance: _currentBalance(a),
                    onTap: () => _openForm(a),
                    onDelete: () => _confirmDelete(a),
                  ),
                )));
            sections.add(const SizedBox(height: AppSpacing.md));
          }

          for (final company in companies) {
            final accs = all.where((a) => a.companyId == company.id).toList();
            if (accs.isEmpty) continue;
            sections.add(_GroupHeader(
              icon: Icons.business_rounded,
              label: company.fantasyName,
              color: company.color,
            ));
            sections.addAll(accs.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AccountTile(
                    account: a,
                    balance: _currentBalance(a),
                    onTap: () => _openForm(a),
                    onDelete: () => _confirmDelete(a),
                  ),
                )));
            sections.add(const SizedBox(height: AppSpacing.md));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                AppSpacing.hero + AppSpacing.xl),
            children: sections,
          );
        },
      ),
    );
  }

  double _computeTotalPJ(List<Account> all) {
    return all
        .where((a) => !a.isPF)
        .fold<double>(0, (s, a) => s + _currentBalance(a));
  }
}

// ─── Summary card (topo) ──────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double totalPF;
  final double totalPJ;

  const _SummaryCard({required this.totalPF, required this.totalPJ});

  @override
  Widget build(BuildContext context) {
    final total = totalPF + totalPJ;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patrimônio total em contas', style: AppTypo.bodySmall),
          const SizedBox(height: 2),
          Text(fmtBRL(total),
              style: AppTypo.numberLarge.copyWith(
                  color: total >= 0
                      ? AppColors.positive
                      : AppColors.negative)),
          const SizedBox(height: AppSpacing.smd),
          Row(
            children: [
              Expanded(
                child: _SplitTile(
                  label: 'PF',
                  value: totalPF,
                  color: AppColors.accent1,
                ),
              ),
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: _SplitTile(
                  label: 'PJ',
                  value: totalPJ,
                  color: AppColors.accent3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitTile extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SplitTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypo.labelSmall.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(fmtBRL(value),
              style: AppTypo.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Group header (PF / Empresa X) ────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _GroupHeader(
      {required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(
          bottom: AppSpacing.smd, top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: AppTypo.label.copyWith(color: c)),
        ],
      ),
    );
  }
}

// ─── Account tile ─────────────────────────────────────────────────────────────

class _AccountTile extends StatelessWidget {
  final Account account;
  final double balance;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AccountTile({
    required this.account,
    required this.balance,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.smd),
          child: Row(
            children: [
              AppIconBadge(
                icon: account.type.icon,
                color: account.color,
                size: 44,
                iconSize: 20,
              ),
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name,
                        style: AppTypo.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(account.bank, style: AppTypo.caption),
                        const SizedBox(width: 6),
                        const Text('·',
                            style: TextStyle(
                                color: AppColors.textMuted)),
                        const SizedBox(width: 6),
                        Text(account.type.label,
                            style: AppTypo.caption),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fmtBRL(balance),
                      style: AppTypo.bodyLarge.copyWith(
                        color: balance >= 0
                            ? AppColors.positive
                            : AppColors.negative,
                        fontWeight: FontWeight.w700,
                      )),
                  Text('saldo atual',
                      style: AppTypo.caption.copyWith(fontSize: 10)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.textMuted, size: 18),
                onPressed: onDelete,
                tooltip: 'Remover',
              ),
            ],
          ),
        ),
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
            Icon(Icons.account_balance_rounded,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text('Nenhuma conta cadastrada',
                style: AppTypo.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Cadastre suas contas bancárias para começar a\n'
              'registrar receitas e despesas.',
              style: AppTypo.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Cadastrar primeira conta',
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

class _AccountFormSheet extends StatefulWidget {
  final AccountStore store;
  final List<Company> companies;
  final Account? initial;

  const _AccountFormSheet({
    required this.store,
    required this.companies,
    this.initial,
  });

  @override
  State<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<_AccountFormSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bankCtrl;
  late TextEditingController _balanceCtrl;
  late AccountType _type;
  String? _companyId; // null = PF
  late Color _color;

  static const _colorPresets = [
    Color(0xFF8A05BE), // Nubank roxo
    Color(0xFFEC7000), // Itaú laranja
    Color(0xFFFF7A00), // Inter laranja
    Color(0xFFCC092F), // Santander vermelho
    Color(0xFF005CA9), // Caixa azul
    Color(0xFFFFD400), // BB amarelo
    Color(0xFF1A1A1A), // BTG preto
    Color(0xFF00A859), // Sicoob verde
    Color(0xFF0EA5E9), // Default blue
    Color(0xFF64748B), // Cinza genérico
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _bankCtrl = TextEditingController(text: a?.bank ?? '');
    _balanceCtrl = TextEditingController(
        text: a?.initialBalance.toStringAsFixed(2).replaceAll('.', ',') ?? '');
    _type = a?.type ?? AccountType.checking;
    _companyId = a?.companyId;
    _color = a?.color ?? _colorPresets.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bankCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameCtrl.text.trim().isNotEmpty &&
      _bankCtrl.text.trim().isNotEmpty;

  void _save() {
    final isEdit = widget.initial != null;
    final balance =
        double.tryParse(_balanceCtrl.text.replaceAll(',', '.')) ?? 0;
    final a = Account(
      id: widget.initial?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      bank: _bankCtrl.text.trim(),
      companyId: _companyId,
      type: _type,
      initialBalance: balance,
      color: _color,
    );
    if (isEdit) {
      widget.store.update(a);
    } else {
      widget.store.add(a);
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
            Text(
              isEdit ? 'Editar conta' : 'Nova conta',
              style: AppTypo.headline,
            ),
            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              controller: _nameCtrl,
              label: 'Nome da conta (ex: Nubank PF)',
              icon: Icons.badge_rounded,
              autofocus: !isEdit,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.smd),
            AppTextField(
              controller: _bankCtrl,
              label: 'Banco',
              icon: Icons.account_balance_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.smd),
            AppTextField(
              controller: _balanceCtrl,
              label: 'Saldo inicial',
              icon: Icons.payments_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Vínculo', style: AppTypo.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                StatusChip(
                  label: 'Pessoa física',
                  color: AppColors.accent1,
                  icon: Icons.person_rounded,
                  selected: _companyId == null,
                  onTap: () => setState(() => _companyId = null),
                ),
                ...widget.companies.map((c) => StatusChip(
                      label: c.fantasyName,
                      color: c.color,
                      icon: Icons.business_rounded,
                      selected: _companyId == c.id,
                      onTap: () => setState(() => _companyId = c.id),
                    )),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Tipo', style: AppTypo.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: AccountType.values.map((t) {
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

            Text('Cor', style: AppTypo.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _colorPresets.map((c) {
                final sel = _color == c;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: sel
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: sel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            AppButton(
              label: isEdit ? 'Salvar alterações' : 'Cadastrar conta',
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
