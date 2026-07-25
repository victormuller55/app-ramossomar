import 'dart:convert';

import 'package:muller_package/muller_package.dart';
import 'package:app_ramos_candidatura/models/error_response_model.dart';

ErrorModel errorModelFromException(Object e) {
  if (e is ApiException) {
    final body = e.response.body.toString().trim();
    if (body.isEmpty) {
      return _fallbackError(e.response.statusCode);
    }

    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      if (map.containsKey('mensagem') ||
          map.containsKey('message') ||
          map.containsKey('erro') ||
          map.containsKey('error')) {
        final model = ErrorResponseModel.fromMap(map).toErrorModel();
        return _normalizeKnownErrors(e.response.statusCode, model);
      }
      return _normalizeKnownErrors(
        e.response.statusCode,
        ErrorModel.fromMap(map),
      );
    } catch (_) {
      return _fallbackError(e.response.statusCode, body: body);
    }
  }

  return ErrorModel.empty();
}

ErrorModel _normalizeKnownErrors(int statusCode, ErrorModel model) {
  final erro = (model.erro ?? '').toUpperCase();
  if (statusCode == 401 &&
      (erro.contains('CREDENCIAIS_INVALIDAS') || erro.isEmpty)) {
    return ErrorModel(
      mensagem: 'Usuário ou senha inválidos.',
      erro: model.erro ?? '',
      tipo: model.tipo ?? '$statusCode',
    );
  }
  if (statusCode == 429 || erro.contains('RATE_LIMIT')) {
    return ErrorModel(
      mensagem: 'Muitas tentativas. Aguarde um momento e tente novamente.',
      erro: model.erro ?? 'RATE_LIMIT',
      tipo: model.tipo ?? '429',
    );
  }
  if (statusCode == 401 && erro.contains('CLIENTE_INVALIDO')) {
    return ErrorModel(
      mensagem: 'App não autorizado a acessar a API. Atualize o aplicativo.',
      erro: model.erro ?? '',
      tipo: model.tipo ?? '$statusCode',
    );
  }
  return model;
}

ErrorModel _fallbackError(int statusCode, {String? body}) {
  var mensagem = body ?? 'Erro desconhecido';
  if (statusCode == 401) {
    mensagem = 'Usuário ou senha inválidos.';
  } else if (statusCode == 403) {
    mensagem = 'Sem permissão para acessar este recurso.';
  } else if (statusCode == 429) {
    mensagem = 'Muitas tentativas. Aguarde um momento e tente novamente.';
  }
  return ErrorModel(mensagem: mensagem, erro: body ?? '', tipo: '$statusCode');
}
