/// Versão do app. Atualize `buildTag` a cada build para
/// verificar qual versão está rodando no ambiente.
class AppVersion {
  static const String version = '1.3.2';
  static const String buildTag = '2026.04.24-nav';

  static String get full => 'v$version · build $buildTag';
}
