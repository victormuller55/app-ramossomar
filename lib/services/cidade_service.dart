import 'dart:convert';

import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';
import 'package:app_ramos_candidatura/function/service/http_helper.dart';
import 'package:app_ramos_candidatura/models/cidade_model.dart';

Future<List<CidadeModel>> listarCidades({String? nome, String? uf}) async {
  final params = <String, String>{};
  if (nome != null && nome.isNotEmpty) params['nome'] = nome;
  if (uf != null && uf.isNotEmpty) params['uf'] = uf;

  final response = await getJson(
    endpoint: AppEndpoints.endpointCidades,
    parameters: params.isEmpty ? null : params,
  );
  final list = jsonDecode(response.body) as List;
  return list
      .map((item) => CidadeModel.fromMap(Map<String, dynamic>.from(item as Map)))
      .toList();
}

Future<CidadeModel> buscarCidadePorId(String id) async {
  final response = await getJson(
    endpoint: AppEndpoints.endpointCidadesPorId,
    parameters: {'id': id},
  );
  return CidadeModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<CidadeModel> buscarCidadePorCodigoIbge(String codigoIbge) async {
  final response = await getJson(
    endpoint: AppEndpoints.endpointCidadesPorCodigoIbge,
    parameters: {'codigo_ibge': codigoIbge},
  );
  return CidadeModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}
