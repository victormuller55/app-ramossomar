import 'dart:convert';

import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/services/usuario_service.dart';

Future<List<UsuarioModel>> listarLideres({bool forceRefresh = false}) async {
  if (!forceRefresh) {
    final cached = await PageDataCache.getJsonList(CacheKeys.usuarios);
    if (cached != null) {
      return cached.map(UsuarioModel.fromMap).toList();
    }
  }

  final response = await getUsuarios(perfil: TipoUsuario.lider);
  final list = jsonDecode(response.body) as List;
  final maps = list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  await PageDataCache.setJsonList(CacheKeys.usuarios, maps);
  return maps.map(UsuarioModel.fromMap).toList();
}

Future<void> excluirLider(String id) async {
  await deleteUsuario(id);
  await PageDataCache.invalidate(CacheKeys.usuarios);
}
