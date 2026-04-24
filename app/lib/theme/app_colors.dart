import 'package:flutter/material.dart';

/// Sistema de cores do MaestroFinanças.
///
/// **Tema claro** (glass / clear colorful) — inspirado no iOS/macOS 26:
/// fundo claro com sutil gradiente azulado, orbs vívidos de cor
/// flutuando, glass branco translúcido, texto escuro.
///
/// **Protocolo Black** (landing) continua com sua paleta própria.
class AppColors {
  // ─── App: tema CLARO ────────────────────────────────────────────────────────
  // Backgrounds — branco-azulado levíssimo
  static const Color bg1 = Color(0xFFF3F6FC);
  static const Color bg2 = Color(0xFFE8EFF9);
  static const Color bg3 = Color(0xFFDDE7F3);

  // Accents VÍVIDOS (se destacam no fundo claro)
  static const Color accent1 = Color(0xFF0EA5E9); // sky blue
  static const Color accent2 = Color(0xFF06B6D4); // cyan
  static const Color accent3 = Color(0xFF6366F1); // indigo
  static const Color accent4 = Color(0xFF14B8A6); // teal
  static const Color accent5 = Color(0xFF8B5CF6); // violet

  // Glass — branco translúcido sobre fundo claro
  static const Color glassWhite = Color(0xB3FFFFFF); // ~70% branco
  static const Color glassBorder = Color(0x1A000000); // ~10% preto (sutil)

  // Texto — escuro para leitura sobre claro
  static const Color textPrimary = Color(0xFF0B1930);   // slate-900
  static const Color textSecondary = Color(0xFF526279); // slate-600
  static const Color textMuted = Color(0xFF8896A8);     // slate-500

  // Semântico (universal)
  static const Color positive = Color(0xFF059669); // verde um toque mais escuro (contraste)
  static const Color negative = Color(0xFFDC2626); // vermelho um toque mais escuro

  // Gradientes
  static const List<Color> backgroundGradient = [bg1, bg2, bg3];
  static const List<Color> accentGradient = [accent1, accent2, accent3];
  static const List<Color> waterGradient = [accent4, accent2, accent1];

  // Noite: sutil diminuição do brilho do fundo (não vira dark mode full)
  static const List<Color> backgroundGradientNight = [
    Color(0xFFDEE5F2),
    Color(0xFFD0DAED),
    Color(0xFFC2CFE5),
  ];

  // ─── Protocolo Black (landing / mentoria) ───────────────────────────────────
  static const Color pbBlack       = Color(0xFF000000);
  static const Color pbBlackSoft   = Color(0xFF0A0A0A);
  static const Color pbCharcoal    = Color(0xFF141414);

  static const Color pbSilver      = Color(0xFFC0C0C0);
  static const Color pbSilverLight = Color(0xFFE8E8E8);
  static const Color pbSilverDark  = Color(0xFF8E8E93);
  static const Color pbSilverMuted = Color(0xFF6B6B6B);

  static const Color pbGold        = Color(0xFFD4AF37);
  static const Color pbGoldLight   = Color(0xFFEAC25A);
  static const Color pbGoldDark    = Color(0xFF9E7E1A);

  static const List<Color> pbSilverGradient = [pbSilverDark, pbSilverLight, pbSilver];
  static const List<Color> pbGoldGradient   = [pbGoldDark, pbGold, pbGoldLight];

  // ─── Night helper (sutil, não dark mode) ────────────────────────────────────
  /// Entre 19h e 7h o fundo fica levemente mais escuro.
  static bool get isNight {
    final h = DateTime.now().hour;
    return h >= 19 || h < 7;
  }
}
