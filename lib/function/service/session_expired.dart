import 'dart:convert';

import 'package:muller_package/muller_package.dart';
import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:app_ramos_candidatura/pages/login_page/entrar_page.dart';

const _mensagemSessaoExpirada =
    'Sua sessão expirou. Faça login novamente para continuar.';

bool _tratandoSessao = false;

bool isSessaoExpirada(Object e) {
  if (e is! ApiException) return false;

  final status = e.response.statusCode;
  if (status != 401 && status != 403) return false;

  final bodyRaw = e.response.body.toString();
  final body = bodyRaw.toUpperCase();

  // Erros de client/credenciais não são sessão expirada.
  if (body.contains('CLIENTE_INVALIDO') ||
      body.contains('CREDENCIAIS_INVALIDAS') ||
      body.contains('RATE_LIMIT')) {
    return false;
  }

  if (body.contains('NAO_AUTENTICADO') ||
      body.contains('TOKEN_INVALIDO') ||
      body.contains('TOKEN JWT') ||
      body.contains('UNAUTHORIZED')) {
    return true;
  }

  try {
    final map = jsonDecode(e.response.body) as Map<String, dynamic>;
    final erro = (map['erro'] ?? map['error'] ?? '').toString().toUpperCase();
    final mensagem = (map['mensagem'] ?? map['message'] ?? '').toString().toUpperCase();

    if (erro.contains('CLIENTE_INVALIDO') ||
        erro.contains('CREDENCIAIS_INVALIDAS')) {
      return false;
    }

    return erro.contains('NAO_AUTENTICADO') ||
        erro.contains('TOKEN_INVALIDO') ||
        mensagem.contains('TOKEN JWT');
  } catch (_) {
    // 401 genérico em rota autenticada → trata como sessão inválida.
    return status == 401;
  }
}

/// Limpa a sessão, volta ao login e avisa o usuário.
/// Retorna `true` se tratou a sessão expirada.
Future<bool> tratarSessaoExpirada(Object e) async {
  if (!isSessaoExpirada(e)) return false;
  if (_tratandoSessao) return true;

  _tratandoSessao = true;
  try {
    await clearToken();
    showToastWarning(message: _mensagemSessaoExpirada);
    open(screen: const LoginPage(), closePrevious: true);
  } finally {
    Future.delayed(const Duration(seconds: 2), () {
      _tratandoSessao = false;
    });
  }
  return true;
}
