import 'dart:convert';

import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/services/usuario_service.dart';

Future<UsuarioModel> salvarLider(UsuarioModel lider) async {
  final isEdit = lider.id != null && lider.id!.isNotEmpty;
  return isEdit ? alterarLider(lider) : criarLider(lider);
}

Future<UsuarioModel> criarLider(UsuarioModel lider) async {
  final response = await postUsuario(lider.toJsonCadastro());
  await PageDataCache.invalidate(CacheKeys.usuarios);

  if (response.body.isEmpty) return lider;
  return UsuarioModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<UsuarioModel> alterarLider(UsuarioModel lider) async {
  final response = await putUsuario(lider.toJsonAlterar());
  await PageDataCache.invalidate(CacheKeys.usuarios);

  if (response.body.isEmpty) return lider;
  return UsuarioModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}
