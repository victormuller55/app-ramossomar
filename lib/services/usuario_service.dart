import 'package:image_picker/image_picker.dart';
import 'package:muller_package/muller_package.dart';
import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';
import 'package:app_ramos_candidatura/function/service/http_helper.dart';

Future<AppResponse> getUsuarios({
  String? nome,
  String? email,
  String? perfil,
  bool? ativo,
}) async {
  final params = <String, String>{};
  if (nome != null && nome.isNotEmpty) params['nome'] = nome;
  if (email != null && email.isNotEmpty) params['email'] = email;
  if (perfil != null && perfil.isNotEmpty) params['perfil'] = perfil;
  if (ativo != null) params['ativo'] = ativo.toString();

  return getHTTP(
    endpoint: AppEndpoints.endpointUsuarios,
    parameters: params.isEmpty ? null : params,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> postUsuario(Map<String, dynamic> body) async {
  return postJson(
    endpoint: AppEndpoints.endpointUsuariosNovo,
    body: body,
  );
}

Future<AppResponse> putUsuario(Map<String, dynamic> body) async {
  return putJson(
    endpoint: AppEndpoints.endpointUsuariosAlterar,
    body: body,
  );
}

Future<void> deleteUsuario(String id) async {
  await deleteJson(
    endpoint: AppEndpoints.endpointUsuariosApagar,
    parameters: {'id': id},
  );
}

Future<AppResponse> uploadImagemUsuario({
  required String id,
  required XFile imagem,
}) async {
  return postMultipartFiles(
    endpoint: AppEndpoints.endpointUsuariosUploadImagem,
    fieldName: 'imagem',
    files: [imagem],
    parameters: {'id': id},
  );
}
