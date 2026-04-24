import 'package:flutter/material.dart';

class AppColors {
  static const Color bg1 = Color(0xFF0A0E1A);
  static const Color bg2 = Color(0xFF0D1B2A);
  static const Color accent1 = Color(0xFF0EA5E9); // sky blue
  static const Color accent2 = Color(0xFF06B6D4); // cyan
  static const Color accent3 = Color(0xFF6366F1); // indigo
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color positive = Color(0xFF10B981);
  static const Color negative = Color(0xFFEF4444);

  static const List<Color> backgroundGradient = [
    Color(0xFF0A0E1A),
    Color(0xFF0D1B2A),
    Color(0xFF0A1628),
  ];

  static const List<Color> accentGradient = [accent1, accent2, accent3];

  // Protocolo Black — mentoria (preto + prata + toques de dourado)
  static const Color pbBlack       = Color(0xFF000000);
  static const Color pbBlackSoft   = Color(0xFF0A0A0A);
  static const Color pbCharcoal    = Color(0xFF141414);

  static const Color pbSilver      = Color(0xFFC0C0C0); // prata principal
  static const Color pbSilverLight = Color(0xFFE8E8E8);
  static const Color pbSilverDark  = Color(0xFF8E8E93);
  static const Color pbSilverMuted = Color(0xFF6B6B6B);

  static const Color pbGold        = Color(0xFFD4AF37); // detalhes de luxo
  static const Color pbGoldLight   = Color(0xFFEAC25A);
  static const Color pbGoldDark    = Color(0xFF9E7E1A);

  static const List<Color> pbSilverGradient = [pbSilverDark, pbSilverLight, pbSilver];
  static const List<Color> pbGoldGradient   = [pbGoldDark, pbGold, pbGoldLight];
}
