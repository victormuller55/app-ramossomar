import 'package:muller_package/muller_package.dart';
import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';
import 'package:app_ramos_candidatura/function/service/http_helper.dart';

Future<AppResponse> getApoiadores({
  String? nome,
  String? cidade,
  String? idLider,
  String? intencaoVoto,
  String? cpf,
  int pagina = 1,
}) async {
  final params = <String, String>{
    'pagina': pagina.toString(),
  };
  if (nome != null && nome.isNotEmpty) params['nome'] = nome;
  if (cidade != null && cidade.isNotEmpty) params['cidade'] = cidade;
  if (idLider != null && idLider.isNotEmpty) params['id_lider'] = idLider;
  if (intencaoVoto != null && intencaoVoto.isNotEmpty) {
    params['intencao_voto'] = intencaoVoto;
  }
  if (cpf != null && cpf.isNotEmpty) params['cpf'] = cpf;

  return getJson(
    endpoint: AppEndpoints.endpointApoiadores,
    parameters: params,
  );
}

Future<AppResponse> postApoiador(Map<String, dynamic> body) async {
  return postJson(
    endpoint: AppEndpoints.endpointApoiadoresNovo,
    body: body,
  );
}

Future<AppResponse> putApoiador(Map<String, dynamic> body) async {
  return putJson(
    endpoint: AppEndpoints.endpointApoiadoresAlterar,
    body: body,
  );
}

Future<void> deleteApoiador(String id) async {
  await deleteJson(
    endpoint: AppEndpoints.endpointApoiadoresApagar,
    parameters: {'id': id},
  );
}
