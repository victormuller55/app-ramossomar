import 'dart:convert';

import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/models/apoiador_model.dart';
import 'package:app_ramos_candidatura/services/apoiador_service.dart';

Future<List<ApoiadorModel>> listarApoiadores({bool forceRefresh = false}) async {
  if (!forceRefresh) {
    final cached = await PageDataCache.getJsonList(CacheKeys.apoiadores);
    if (cached != null) {
      return cached.map(ApoiadorModel.fromMap).toList();
    }
  }

  final response = await getApoiadores();
  final list = jsonDecode(response.body) as List;
  final maps = list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  await PageDataCache.setJsonList(CacheKeys.apoiadores, maps);
  return maps.map(ApoiadorModel.fromMap).toList();
}

Future<void> excluirApoiador(String id) async {
  await deleteApoiador(id);
  await PageDataCache.invalidate(CacheKeys.apoiadores);
}
