import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_version.dart';

/// Badge discreto que exibe versão + tag do build.
/// Útil para confirmar qual versão está em produção.
class VersionBadge extends StatelessWidget {
  final Color? color;
  final double fontSize;
  final TextAlign textAlign;

  const VersionBadge({
    super.key,
    this.color,
    this.fontSize = 10,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      AppVersion.full,
      textAlign: textAlign,
      style: GoogleFonts.robotoMono(
        color: color ?? Colors.white.withValues(alpha: 0.35),
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}
