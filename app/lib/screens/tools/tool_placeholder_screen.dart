import 'package:flutter/material.dart';
import '../../models/app_tool.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/tool_scaffold.dart';

class ToolPlaceholderScreen extends StatelessWidget {
  final String toolId;

  const ToolPlaceholderScreen({super.key, required this.toolId});

  AppTool? get _tool =>
      appTools.where((t) => t.id == toolId).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final tool = _tool;

    if (tool == null) {
      return Scaffold(
        backgroundColor: AppColors.bg1,
        body: Center(
          child: Text('Ferramenta não encontrada',
              style: AppTypo.body.copyWith(color: Colors.white)),
        ),
      );
    }

    return ToolScaffold(
      toolId: toolId,
      content: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl + 8),
            radius: AppRadius.xxl,
            accentColor: tool.color,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIconBadge(
                  icon: tool.icon,
                  color: tool.color,
                  size: 80,
                  iconSize: 40,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(tool.name,
                    style: AppTypo.headline,
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(tool.subtitle,
                    style: AppTypo.bodySmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                Text('Em desenvolvimento',
                    style: AppTypo.body.copyWith(
                        color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.md),
                StatusChip(
                  label: 'Em breve',
                  color: tool.color,
                  icon: Icons.construction_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
