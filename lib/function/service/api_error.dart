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
        return ErrorResponseModel.fromMap(map).toErrorModel();
      }
      return ErrorModel.fromMap(map);
    } catch (_) {
      return _fallbackError(e.response.statusCode, body: body);
    }
  }

  return ErrorModel.empty();
}

ErrorModel _fallbackError(int statusCode, {String? body}) {
  var mensagem = body ?? 'Erro desconhecido';
  if (statusCode == 401) {
    mensagem = 'E-mail ou senha inválidos.';
  } else if (statusCode == 403) {
    mensagem = 'Sem permissão para acessar este recurso.';
  }
  return ErrorModel(mensagem: mensagem, erro: body ?? '', tipo: '$statusCode');
}
