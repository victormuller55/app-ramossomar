import 'package:muller_package/muller_package.dart';
import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';
import 'package:app_ramos_candidatura/function/service/http_helper.dart';

Future<AppResponse> getPublicacoes({
  String? titulo,
  String? idAutor,
}) async {
  final params = <String, String>{};
  if (titulo != null && titulo.isNotEmpty) params['titulo'] = titulo;
  if (idAutor != null && idAutor.isNotEmpty) params['id_autor'] = idAutor;

  return getHTTP(
    endpoint: AppEndpoints.endpointPublicacoes,
    parameters: params.isEmpty ? null : params,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> postPublicacao(Map<String, dynamic> body) async {
  return postJson(
    endpoint: AppEndpoints.endpointPublicacoesNovo,
    body: body,
  );
}
