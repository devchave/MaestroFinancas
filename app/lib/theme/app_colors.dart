import 'package:flutter/material.dart';

/// Sistema de cores do MaestroFinanças.
///
/// Duas paletas distintas — cada uma para seu contexto:
///
/// 1. **App** (login, home, ferramentas): glass / água / vivo
///    Tons vívidos de azul, ciano, índigo, teal e violeta sobre fundo
///    escuro azulado. Transmite movimento e tecnologia.
///
/// 2. **Protocolo Black** (landing de venda da mentoria): luxo premium
///    Preto puro + prata + dourado. Transmite exclusividade.
///
/// A partir das 19h até as 7h o fundo do app fica mais escuro
/// (`AppColors.isNight` + gradientes `*Night`).
class AppColors {
  // ─── App: paleta glass / água / vivo ────────────────────────────────────────
  static const Color bg1 = Color(0xFF0A0E1A);
  static const Color bg2 = Color(0xFF0D1B2A);

  // Versão noturna (19h-7h)
  static const Color bgNight1 = Color(0xFF040711);
  static const Color bgNight2 = Color(0xFF060E18);

  // Accents vívidos
  static const Color accent1 = Color(0xFF0EA5E9); // sky blue
  static const Color accent2 = Color(0xFF06B6D4); // cyan
  static const Color accent3 = Color(0xFF6366F1); // indigo
  static const Color accent4 = Color(0xFF14B8A6); // teal / aqua (água)
  static const Color accent5 = Color(0xFF8B5CF6); // violet (vivo)

  // Glass
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);

  // Semântico (não muda com a marca)
  static const Color positive = Color(0xFF10B981);
  static const Color negative = Color(0xFFEF4444);

  // Gradientes
  static const List<Color> backgroundGradient = [
    bg1,
    bg2,
    Color(0xFF0A1628),
  ];
  static const List<Color> backgroundGradientNight = [
    bgNight1,
    bgNight2,
    Color(0xFF04101C),
  ];
  static const List<Color> accentGradient = [accent1, accent2, accent3];
  static const List<Color> waterGradient = [accent4, accent2, accent1];

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

  // ─── Night mode ─────────────────────────────────────────────────────────────
  /// Modo noturno ativo entre 19h e 7h (horário local).
  static bool get isNight {
    final h = DateTime.now().hour;
    return h >= 19 || h < 7;
  }
}
