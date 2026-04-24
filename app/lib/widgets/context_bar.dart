import 'package:flutter/material.dart';
import '../models/finance.dart';
import '../state/app_context.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_ui.dart';

/// Barra horizontal de seleção de contexto (Todos / PF / cada Empresa).
/// Fica no topo do AppShell em telas que respeitam o filtro.
class ContextBar extends StatelessWidget {
  const ContextBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(
          [AppContext.instance, CompanyStore.instance]),
      builder: (context, _) {
        final ctx = AppContext.instance;
        final companies = CompanyStore.instance.all;

        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen, vertical: AppSpacing.sm),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.glassBorder),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                StatusChip(
                  label: 'Todos',
                  icon: Icons.all_inclusive_rounded,
                  color: const Color(0xFF64748B),
                  selected: ctx.isAll,
                  onTap: () => ctx.setAll(),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusChip(
                  label: 'PF',
                  icon: Icons.person_rounded,
                  color: AppColors.accent1,
                  selected: ctx.isPF,
                  onTap: () => ctx.setPF(),
                ),
                for (final c in companies) ...[
                  const SizedBox(width: AppSpacing.sm),
                  StatusChip(
                    label: c.fantasyName,
                    icon: Icons.business_rounded,
                    color: c.color,
                    selected: ctx.isSpecificCompany(c.id),
                    onTap: () => ctx.setCompany(c.id),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
