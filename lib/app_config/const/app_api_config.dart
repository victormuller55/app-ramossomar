/// Credenciais e metadados do client mobile para a API em produção.
///
/// Ver `docs/SEGURANCA_APP_MOBILE.md` na API Ramos Somar.
class AppApiConfig {
  AppApiConfig._();

  static const String clientId = 'ramossomar-mobile';
  static const String clientSecret = 'a7K9xP2mQ5vL8R1wZ4nB6yT0C3dE2fG8hJ4kM7nP9qR1sT3uV5wX7yZ9aB1cD3eF';
  /// Deve acompanhar `version` do `pubspec.yaml` (sem build number).
  static const String appVersion = '1.0.0';

  static const String privacyPolicyUrl =
      'https://convertix.net.br/pages/politica-privacidade-ramos-somar.html';
}
