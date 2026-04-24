import 'package:flutter/material.dart';
import '../../models/finance.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_ui.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final _store = CompanyStore.instance;

  void _openForm([Company? company]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CompanyFormSheet(
        store: _store,
        initial: company,
      ),
    );
  }

  void _confirmDelete(Company c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg1,
        title: Text('Remover empresa?',
            style: AppTypo.title),
        content: Text(
          'Tem certeza que deseja remover "${c.fantasyName}"?\n\n'
          'As contas e transações vinculadas continuarão existindo mas perderão o vínculo.',
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
    if (confirmed == true) {
      _store.remove(c.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showTopBar: true,
      currentId: 'companies',
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent1,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Nova empresa',
            style: AppTypo.body.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      content: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final companies = _store.all;
          if (companies.isEmpty) {
            return _EmptyState(onAdd: () => _openForm());
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                AppSpacing.hero + AppSpacing.xl),
            itemCount: companies.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.smd),
            itemBuilder: (context, i) {
              final c = companies[i];
              return _CompanyTile(
                company: c,
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

class _CompanyTile extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CompanyTile({
    required this.company,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accountsCount = AccountStore.instance
        .forCompany(company.id)
        .length;

    return AppCard(
      padding: EdgeInsets.zero,
      accentColor: company.color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              AppIconBadge(
                icon: Icons.business_rounded,
                color: company.color,
                size: 48,
                iconSize: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(company.fantasyName,
                              style: AppTypo.title,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (!company.active)
                          StatusChip(
                            label: 'Inativa',
                            color: AppColors.textMuted,
                            icon: Icons.pause_circle_outline_rounded,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(company.name,
                        style: AppTypo.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.fingerprint_rounded,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(company.cnpj, style: AppTypo.caption),
                        const SizedBox(width: AppSpacing.smd),
                        Icon(Icons.gavel_rounded,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(company.regime.label, style: AppTypo.caption),
                        const SizedBox(width: AppSpacing.smd),
                        Icon(Icons.account_balance_rounded,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          accountsCount == 1
                              ? '1 conta'
                              : '$accountsCount contas',
                          style: AppTypo.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.textMuted, size: 20),
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
            Icon(Icons.business_rounded,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text('Nenhuma empresa cadastrada',
                style: AppTypo.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Cadastre suas empresas (PJ) para organizar contas,\n'
              'cartões, funcionários e notas fiscais separadamente.',
              style: AppTypo.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Cadastrar primeira empresa',
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
// Form sheet — criar/editar
// ════════════════════════════════════════════════════════════════════════════

class _CompanyFormSheet extends StatefulWidget {
  final CompanyStore store;
  final Company? initial;

  const _CompanyFormSheet({required this.store, this.initial});

  @override
  State<_CompanyFormSheet> createState() => _CompanyFormSheetState();
}

class _CompanyFormSheetState extends State<_CompanyFormSheet> {
  late TextEditingController _fantasyCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _cnpjCtrl;
  late TaxRegime _regime;
  late Color _color;
  late bool _active;

  static const _colorPresets = [
    Color(0xFF0EA5E9),
    Color(0xFF06B6D4),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF14B8A6),
    Color(0xFFEF4444),
    Color(0xFF64748B),
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _fantasyCtrl = TextEditingController(text: c?.fantasyName ?? '');
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _cnpjCtrl = TextEditingController(text: c?.cnpj ?? '');
    _regime = c?.regime ?? TaxRegime.simples;
    _color = c?.color ?? _colorPresets.first;
    _active = c?.active ?? true;
  }

  @override
  void dispose() {
    _fantasyCtrl.dispose();
    _nameCtrl.dispose();
    _cnpjCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _fantasyCtrl.text.trim().isNotEmpty &&
      _nameCtrl.text.trim().isNotEmpty;

  void _save() {
    final isEdit = widget.initial != null;
    final c = Company(
      id: widget.initial?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      fantasyName: _fantasyCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      cnpj: _cnpjCtrl.text.trim(),
      regime: _regime,
      color: _color,
      active: _active,
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
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isEdit ? 'Editar empresa' : 'Nova empresa',
              style: AppTypo.headline,
            ),
            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              controller: _fantasyCtrl,
              label: 'Nome fantasia',
              icon: Icons.storefront_rounded,
              autofocus: !isEdit,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.smd),
            AppTextField(
              controller: _nameCtrl,
              label: 'Razão social',
              icon: Icons.business_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.smd),
            AppTextField(
              controller: _cnpjCtrl,
              label: 'CNPJ',
              icon: Icons.fingerprint_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Regime tributário', style: AppTypo.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: TaxRegime.values.map((r) {
                return StatusChip(
                  label: r.label,
                  color: AppColors.accent1,
                  selected: _regime == r,
                  onTap: () => setState(() => _regime = r),
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
                      boxShadow: [
                        BoxShadow(
                          color: c.withValues(alpha: 0.4),
                          blurRadius: sel ? 12 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: sel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Empresa ativa', style: AppTypo.bodyLarge),
              subtitle: Text(
                _active
                    ? 'Operando normalmente'
                    : 'Pausada — não aparece em listas de seleção',
                style: AppTypo.bodySmall,
              ),
              value: _active,
              activeColor: AppColors.accent1,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: AppSpacing.lg),

            AppButton(
              label: isEdit ? 'Salvar alterações' : 'Cadastrar empresa',
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
