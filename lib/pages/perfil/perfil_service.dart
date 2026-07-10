import 'dart:convert';

import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/services/usuario_service.dart';
import 'package:muller_package/muller_package.dart';

Future<UsuarioModel> carregarPerfil() async {
  final usuario = await getUsuarioLogado();
  if (usuario == null || usuario.id == null || usuario.id!.isEmpty) {
    throw ApiException(
      AppResponse(
        statusCode: 401,
        body: jsonEncode({
          'mensagem': 'Sessão inválida. Faça login novamente.',
          'erro': 'NAO_AUTENTICADO',
        }),
      ),
    );
  }
  return usuario;
}

Future<UsuarioModel> salvarPerfil(UsuarioModel usuario) async {
  final response = await putUsuario(usuario.toJsonAlterar());
  final atualizado = response.body.isEmpty
      ? usuario
      : UsuarioModel.fromMap(
          Map<String, dynamic>.from(jsonDecode(response.body) as Map),
        );

  await saveUsuarioLogado(atualizado);
  return atualizado;
}
