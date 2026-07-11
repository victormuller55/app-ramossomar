import 'dart:convert';

import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/services/usuario_service.dart';
import 'package:image_picker/image_picker.dart';
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

  final atual = await getUsuarioLogado();
  atualizado.token = atual?.token ?? atualizado.token;
  atualizado.refreshToken = atual?.refreshToken ?? atualizado.refreshToken;
  atualizado.expiraEm = atual?.expiraEm ?? atualizado.expiraEm;
  if (atualizado.foto == null || atualizado.foto!.isEmpty) {
    atualizado.foto = atual?.foto;
  }

  await saveUsuarioLogado(atualizado);
  return atualizado;
}

Future<UsuarioModel> uploadImagemPerfil(XFile imagem) async {
  final atual = await carregarPerfil();
  final id = atual.id;
  if (id == null || id.isEmpty) {
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

  final response = await uploadImagemUsuario(id: id, imagem: imagem);
  final atualizado = response.body.isEmpty
      ? atual
      : UsuarioModel.fromMap(
          Map<String, dynamic>.from(jsonDecode(response.body) as Map),
        );

  atualizado.token = atual.token;
  atualizado.refreshToken = atual.refreshToken;
  atualizado.expiraEm = atual.expiraEm;

  await saveUsuarioLogado(atualizado);
  return atualizado;
}
