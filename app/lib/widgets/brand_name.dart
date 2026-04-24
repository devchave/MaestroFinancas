import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Marca "PROTOCOLO BLACK" com tipografia inspirada no logotipo real
/// (PROTOCOLO entre colchetes em sans-serif + BLACK condensado angular).
class BrandName extends StatelessWidget {
  final double blackSize;
  final bool stacked;
  final Color? color;

  const BrandName({
    super.key,
    this.blackSize = 48,
    this.stacked = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.pbSilverLight;
    final protoSize = blackSize * 0.32;

    Widget proto = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Bracket(char: '[', size: protoSize, color: c),
        SizedBox(width: protoSize * 0.5),
        Text(
          'PROTOCOLO',
          style: GoogleFonts.inter(
            color: c,
            fontSize: protoSize,
            fontWeight: FontWeight.w600,
            letterSpacing: protoSize * 0.2,
          ),
        ),
        SizedBox(width: protoSize * 0.5),
        _Bracket(char: ']', size: protoSize, color: c),
      ],
    );

    Widget black = ShaderMask(
      shaderCallback: (b) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.pbSilverLight,
          AppColors.pbSilver,
          AppColors.pbSilverDark,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(b),
      child: Text(
        'BLACK',
        style: GoogleFonts.chakraPetch(
          color: Colors.white,
          fontSize: blackSize,
          fontWeight: FontWeight.w700,
          letterSpacing: blackSize * 0.08,
          height: 1.0,
        ),
      ),
    );

    if (!stacked) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [proto, SizedBox(width: blackSize * 0.2), black],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        proto,
        SizedBox(height: blackSize * 0.05),
        black,
      ],
    );
  }
}

class _Bracket extends StatelessWidget {
  final String char;
  final double size;
  final Color color;
  const _Bracket({required this.char, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      char,
      style: GoogleFonts.inter(
        color: color,
        fontSize: size * 1.3,
        fontWeight: FontWeight.w300,
        height: 1.0,
      ),
    );
  }
}
