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
  // Backgrounds — azulado médio-claro (não branco puro — dá contraste p/ texto)
  static const Color bg1 = Color(0xFFD8E0EE);
  static const Color bg2 = Color(0xFFC6D2E4);
  static const Color bg3 = Color(0xFFB4C4DA);

  // Accents VÍVIDOS (se destacam no fundo claro)
  static const Color accent1 = Color(0xFF0284C7); // sky blue um tom mais escuro
  static const Color accent2 = Color(0xFF0891B2); // cyan escurecida
  static const Color accent3 = Color(0xFF4F46E5); // indigo escurecida
  static const Color accent4 = Color(0xFF0D9488); // teal escurecida
  static const Color accent5 = Color(0xFF7C3AED); // violet escurecida

  // Glass — branco translúcido sobre fundo médio-claro
  static const Color glassWhite = Color(0xCCFFFFFF); // ~80% branco
  static const Color glassBorder = Color(0x26000000); // ~15% preto (mais visível)

  // Texto — escuro forte para leitura sobre claro
  static const Color textPrimary = Color(0xFF0B1930);   // slate-900
  static const Color textSecondary = Color(0xFF334155); // slate-700 (mais escuro)
  static const Color textMuted = Color(0xFF64748B);     // slate-500

  // Semântico (universal)
  static const Color positive = Color(0xFF047857); // verde escurecido p/ contraste
  static const Color negative = Color(0xFFB91C1C); // vermelho escurecido p/ contraste

  // Gradientes
  static const List<Color> backgroundGradient = [bg1, bg2, bg3];
  static const List<Color> accentGradient = [accent1, accent2, accent3];
  static const List<Color> waterGradient = [accent4, accent2, accent1];

  // Noite: sutil diminuição do brilho
  static const List<Color> backgroundGradientNight = [
    Color(0xFFB8C3D6),
    Color(0xFFA5B2C9),
    Color(0xFF94A3BC),
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
