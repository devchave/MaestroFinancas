/// Tokens de raio de borda — mantém consistência visual entre cards,
/// botões, inputs e chips.
///
/// Uso:
///   borderRadius: BorderRadius.circular(AppRadius.md)
class AppRadius {
  AppRadius._();

  /// 6 — badges pequenos (tags inline)
  static const double xs = 6;

  /// 10 — chips, botões compactos, ícones em botões
  static const double sm = 10;

  /// 12 — inputs, botões padrão
  static const double md = 12;

  /// 16 — cards padrão (TxRow, cards pequenos)
  static const double lg = 16;

  /// 20 — cards grandes (balance card, hero cards)
  static const double xl = 20;

  /// 28 — bottom sheets, dialogs, cards hero
  static const double xxl = 28;

  /// 999 — pills, circulares
  static const double pill = 999;
}
