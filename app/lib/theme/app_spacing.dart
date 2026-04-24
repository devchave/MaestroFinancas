/// Tokens de espaçamento do app — grade base 4px.
///
/// Use sempre essas constantes em vez de números mágicos:
///   padding: const EdgeInsets.all(AppSpacing.md)
///   SizedBox(height: AppSpacing.lg)
class AppSpacing {
  AppSpacing._();

  /// 4 — separação mínima entre ícone e rótulo
  static const double xs = 4;

  /// 8 — dentro de chips, badges pequenos
  static const double sm = 8;

  /// 12 — padding interno de inputs, small cards
  static const double smd = 12;

  /// 16 — padding padrão de cards, separação entre elementos relacionados
  static const double md = 16;

  /// 20 — padding horizontal padrão de telas
  static const double screen = 20;

  /// 24 — separação entre seções dentro de uma tela
  static const double lg = 24;

  /// 32 — separação entre blocos grandes
  static const double xl = 32;

  /// 48 — separação entre seções muito distintas
  static const double xxl = 48;

  /// 64 — separação hero
  static const double hero = 64;
}
