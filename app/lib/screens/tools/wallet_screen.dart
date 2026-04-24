import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/finance.dart';
import '../../models/transaction.dart';
import '../../state/app_context.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_ui.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _accountStore = AccountStore.instance;
  final _txStore = TransactionStore.instance;
  final _companyStore = CompanyStore.instance;

  double _balance(Account a) =>
      a.initialBalance + _txStore.netFlowForAccount(a.id);

  @override
  Widget build(BuildContext context) {
    return AppShell(
      showTopBar: true,
      currentId: 'wallet',
      content: ListenableBuilder(
        listenable: Listenable.merge([
          _accountStore,
          _txStore,
          _companyStore,
          AppContext.instance,
        ]),
        builder: (context, _) {
          final allAccounts =
              AppContext.instance.filterAccounts(_accountStore.all);

          if (allAccounts.isEmpty) {
            return _EmptyState(
              onOpenAccounts: () => context.go('/app/accounts'),
            );
          }

          // Ordenar por saldo desc
          final ranked = [...allAccounts]
            ..sort((a, b) => _balance(b).compareTo(_balance(a)));

          final total =
              ranked.fold<double>(0, (s, a) => s + _balance(a));
          final totalPositive = ranked
              .where((a) => _balance(a) > 0)
              .fold<double>(0, (s, a) => s + _balance(a));

          // Separar por kind
          final pfAccounts = ranked.where((a) => a.isPF).toList();
          final totalPF =
              pfAccounts.fold<double>(0, (s, a) => s + _balance(a));
          final totalPJ = total - totalPF;

          // Agrupar por categoria/tipo
          final byType = <AccountType, double>{};
          for (final a in ranked) {
            byType[a.type] = (byType[a.type] ?? 0) + _balance(a);
          }
          final sortedTypes = byType.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                AppSpacing.hero + AppSpacing.xl),
            children: [
              // ── Card de patrimônio total ─────────────────────────────
              _TotalCard(
                total: total,
                totalPF: totalPF,
                totalPJ: totalPJ,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Distribuição por conta (bar horizontal) ──────────────
              const SectionLabel('DISTRIBUIÇÃO POR CONTA'),
              const SizedBox(height: AppSpacing.smd),
              _DistributionBar(
                accounts: ranked.where((a) => _balance(a) > 0).toList(),
                total: totalPositive,
                balanceFn: _balance,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Distribuição por tipo de conta ───────────────────────
              const SectionLabel('POR TIPO DE CONTA'),
              const SizedBox(height: AppSpacing.smd),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: sortedTypes.asMap().entries.map((entry) {
                    final type = entry.value.key;
                    final value = entry.value.value;
                    final pct = total > 0 ? value / total : 0.0;
                    final isLast = entry.key == sortedTypes.length - 1;
                    return Padding(
                      padding:
                          EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.smd),
                      child: _TypeRow(
                          type: type, value: value, pct: pct),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Lista de contas (maior → menor saldo) ────────────────
              const SectionLabel('CONTAS'),
              const SizedBox(height: AppSpacing.smd),
              ...ranked.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _AccountRow(
                      account: a,
                      balance: _balance(a),
                      totalPositive: totalPositive,
                      company: a.companyId == null
                          ? null
                          : _companyStore.byId(a.companyId!),
                    ),
                  )),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/app/accounts'),
                  icon: const Icon(Icons.settings_rounded, size: 16),
                  label: Text('Gerenciar contas',
                      style: AppTypo.bodySmall
                          .copyWith(color: AppColors.accent1)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Card de patrimônio total ─────────────────────────────────────────────────

class _TotalCard extends StatelessWidget {
  final double total;
  final double totalPF;
  final double totalPJ;

  const _TotalCard({
    required this.total,
    required this.totalPF,
    required this.totalPJ,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Patrimônio líquido em contas',
                  style: AppTypo.bodySmall),
              const Spacer(),
              _ContextBadge(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            fmtBRL(total),
            style: AppTypo.numberLarge.copyWith(
              color: total >= 0 ? AppColors.positive : AppColors.negative,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (totalPF != 0)
                Expanded(
                  child: _SplitTile(
                    label: 'Pessoa física',
                    value: totalPF,
                    color: AppColors.accent1,
                    icon: Icons.person_rounded,
                  ),
                ),
              if (totalPF != 0 && totalPJ != 0)
                const SizedBox(width: AppSpacing.smd),
              if (totalPJ != 0)
                Expanded(
                  child: _SplitTile(
                    label: 'Empresas',
                    value: totalPJ,
                    color: AppColors.accent3,
                    icon: Icons.business_rounded,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

class _SplitTile extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _SplitTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.smd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(label, style: AppTypo.labelSmall.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 2),
          Text(fmtBRL(value),
              style: AppTypo.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Barra de distribuição horizontal ─────────────────────────────────────────

class _DistributionBar extends StatelessWidget {
  final List<Account> accounts;
  final double total;
  final double Function(Account) balanceFn;

  const _DistributionBar({
    required this.accounts,
    required this.total,
    required this.balanceFn,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty || total <= 0) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text('Nenhum saldo positivo para distribuir.',
            style: AppTypo.bodySmall),
      );
    }
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: SizedBox(
              height: 14,
              child: Row(
                children: accounts.map((a) {
                  final flex = (balanceFn(a) / total * 1000).round();
                  return Expanded(
                    flex: flex > 0 ? flex : 1,
                    child: Container(color: a.color),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.smd),
          Wrap(
            spacing: AppSpacing.smd,
            runSpacing: AppSpacing.sm,
            children: accounts.map((a) {
              final pct = balanceFn(a) / total * 100;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: a.color,
                      borderRadius:
                          BorderRadius.circular(AppRadius.xs - 3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('${a.name} (${pct.toStringAsFixed(0)}%)',
                      style: AppTypo.caption),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Tipo row ─────────────────────────────────────────────────────────────────

class _TypeRow extends StatelessWidget {
  final AccountType type;
  final double value;
  final double pct;

  const _TypeRow(
      {required this.type, required this.value, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.accent3.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(type.icon, color: AppColors.accent3, size: 16),
        ),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(type.label,
                        style: AppTypo.bodySmall.copyWith(
                            fontWeight: FontWeight.w500)),
                  ),
                  Text('${(pct * 100).toStringAsFixed(0)}%',
                      style: AppTypo.caption),
                  const SizedBox(width: 8),
                  Text(fmtBRL(value),
                      style: AppTypo.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor:
                      AppColors.accent3.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(
                      AppColors.accent3),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Account row ──────────────────────────────────────────────────────────────

class _AccountRow extends StatelessWidget {
  final Account account;
  final double balance;
  final double totalPositive;
  final Company? company;

  const _AccountRow({
    required this.account,
    required this.balance,
    required this.totalPositive,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalPositive > 0 && balance > 0
        ? balance / totalPositive
        : 0.0;
    return AppCard(
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
                    style: AppTypo.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(account.bank, style: AppTypo.caption),
                    const SizedBox(width: 6),
                    const Text('·',
                        style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(width: 6),
                    Text(account.type.label, style: AppTypo.caption),
                    if (company != null) ...[
                      const SizedBox(width: 6),
                      const Text('·',
                          style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(width: 6),
                      Icon(Icons.business_rounded,
                          size: 10, color: company!.color),
                      const SizedBox(width: 2),
                      Text(company!.fantasyName,
                          style: AppTypo.caption
                              .copyWith(color: company!.color)),
                    ],
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
              if (pct > 0)
                Text('${(pct * 100).toStringAsFixed(0)}% do total',
                    style: AppTypo.caption.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onOpenAccounts;
  const _EmptyState({required this.onOpenAccounts});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text('Nenhuma conta no contexto atual',
                style: AppTypo.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Troque o filtro acima ou cadastre contas\n'
              'para ver seu patrimônio consolidado.',
              style: AppTypo.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Gerenciar contas',
              icon: Icons.account_balance_rounded,
              onPressed: onOpenAccounts,
            ),
          ],
        ),
      ),
    );
  }
}
