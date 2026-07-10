import 'package:flutter/foundation.dart';

/// Host da API na máquina de desenvolvimento.
/// Emulador Android: 10.0.2.2 | iOS Simulator / desktop / web: localhost
/// Em dispositivo físico na mesma Wi-Fi, troque [_hostLocal] pelo IP do notebook.
const String _hostEmuladorAndroid = '10.0.2.2';
const String _hostLocal = 'localhost';
const int _porta = 8080;

String get server {
  final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? _hostEmuladorAndroid
      : _hostLocal;
  return 'http://$host:$_porta';
}

String get api => '$server/api/v1/ramossomar';

String fotoUrl(String? path) {
  if (path == null || path.trim().isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '$server$path';
}

class AppEndpoints {
  // Auth
  static String endpointAuthLogin = '$api/auth/login';

  // Usuários
  static String endpointUsuarios = '$api/usuarios';
  static String endpointUsuariosNovo = '$api/usuarios/novo';
  static String endpointUsuariosAlterar = '$api/usuarios/alterar-dados';
  static String endpointUsuariosApagar = '$api/usuarios/apagar';

  // Apoiadores
  static String endpointApoiadores = '$api/apoiadores';
  static String endpointApoiadoresNovo = '$api/apoiadores/novo';
  static String endpointApoiadoresAlterar = '$api/apoiadores/alterar-dados';
  static String endpointApoiadoresApagar = '$api/apoiadores/apagar';

  // Histórico de apoiadores
  static String endpointHistoricoApoiadores = '$api/historico-apoiadores';
  static String endpointHistoricoApoiadoresNovo = '$api/historico-apoiadores/novo';
  static String endpointHistoricoApoiadoresAlterar = '$api/historico-apoiadores/alterar-dados';
  static String endpointHistoricoApoiadoresApagar = '$api/historico-apoiadores/apagar';

  // Publicações
  static String endpointPublicacoes = '$api/publicacoes';
  static String endpointPublicacoesNovo = '$api/publicacoes/novo';
  static String endpointPublicacoesAlterar = '$api/publicacoes/alterar-dados';
  static String endpointPublicacoesApagar = '$api/publicacoes/apagar';

  // Relatórios
  static String endpointRelatoriosApoiadores = '$api/relatorios/apoiadores';

  // Tokens refresh
  static String endpointTokensRefresh = '$api/tokens-refresh';
  static String endpointTokensRefreshNovo = '$api/tokens-refresh/novo';
  static String endpointTokensRefreshAlterar = '$api/tokens-refresh/alterar-dados';
  static String endpointTokensRefreshApagar = '$api/tokens-refresh/apagar';
}
