import 'dart:convert';

import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';
import 'package:app_ramos_candidatura/function/service/http_helper.dart';
import 'package:app_ramos_candidatura/models/local_votacao_model.dart';

Future<List<LocalVotacaoModel>> listarLocaisVotacao({
  String? nome,
  String? idCidade,
  String? codigoIbge,
  String? zonaEleitoral,
  bool? ativo = true,
}) async {
  final params = <String, String>{};
  if (nome != null && nome.isNotEmpty) params['nome'] = nome;
  if (idCidade != null && idCidade.isNotEmpty) params['id_cidade'] = idCidade;
  if (codigoIbge != null && codigoIbge.isNotEmpty) {
    params['codigo_ibge'] = codigoIbge;
  }
  if (zonaEleitoral != null && zonaEleitoral.isNotEmpty) {
    params['zona_eleitoral'] = zonaEleitoral;
  }
  if (ativo != null) params['ativo'] = ativo.toString();

  final response = await getJson(
    endpoint: AppEndpoints.endpointLocaisVotacao,
    parameters: params.isEmpty ? null : params,
  );
  final list = jsonDecode(response.body) as List;
  return list
      .map(
        (item) => LocalVotacaoModel.fromMap(
          Map<String, dynamic>.from(item as Map),
        ),
      )
      .toList();
}

Future<LocalVotacaoModel> buscarLocalVotacaoPorId(String id) async {
  final response = await getJson(
    endpoint: AppEndpoints.endpointLocaisVotacaoPorId,
    parameters: {'id': id},
  );
  return LocalVotacaoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<LocalVotacaoModel> criarLocalVotacao(LocalVotacaoModel local) async {
  final response = await postJson(
    endpoint: AppEndpoints.endpointLocaisVotacaoNovo,
    body: local.toJsonCadastro(),
  );
  return LocalVotacaoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<LocalVotacaoModel> alterarLocalVotacao(LocalVotacaoModel local) async {
  final response = await putJson(
    endpoint: AppEndpoints.endpointLocaisVotacaoAlterar,
    body: local.toJsonAlterar(),
  );
  return LocalVotacaoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<void> apagarLocalVotacao(String id) async {
  await deleteJson(
    endpoint: AppEndpoints.endpointLocaisVotacaoApagar,
    parameters: {'id': id},
  );
}
