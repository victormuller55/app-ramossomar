import 'dart:convert';

import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/models/apoiador_model.dart';
import 'package:app_ramos_candidatura/services/apoiador_service.dart';

Future<ApoiadorModel> salvarApoiador(ApoiadorModel apoiador) async {
  final isEdit = apoiador.id != null && apoiador.id!.isNotEmpty;
  return isEdit ? alterarApoiador(apoiador) : criarApoiador(apoiador);
}

Future<ApoiadorModel> criarApoiador(ApoiadorModel apoiador) async {
  final response = await postApoiador(apoiador.toJsonCadastro());
  await PageDataCache.invalidate(CacheKeys.apoiadores);

  if (response.body.isEmpty) return apoiador;
  return ApoiadorModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<ApoiadorModel> alterarApoiador(ApoiadorModel apoiador) async {
  final response = await putApoiador(apoiador.toJsonAlterar());
  await PageDataCache.invalidate(CacheKeys.apoiadores);

  if (response.body.isEmpty) return apoiador;
  return ApoiadorModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}
