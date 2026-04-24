import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/app_tool.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_container.dart';
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
              style: GoogleFonts.inter(color: Colors.white)),
        ),
      );
    }

    return ToolScaffold(
      toolId: toolId,
      content: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: GlassContainer(
            padding: const EdgeInsets.all(40),
            borderRadius: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tool.color, tool.color.withValues(alpha: 0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: tool.color.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(tool.icon, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                Text(
                  tool.name,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tool.subtitle,
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Text(
                  'Em desenvolvimento',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: tool.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.construction_rounded,
                          color: tool.color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Em breve',
                        style: GoogleFonts.inter(
                          color: tool.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
