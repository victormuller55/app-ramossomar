import 'dart:convert';

import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/models/publicacao_model.dart';
import 'package:app_ramos_candidatura/services/publicacao_service.dart';

Future<List<PublicacaoModel>> listarPublicacoes({bool forceRefresh = false}) async {
  if (!forceRefresh) {
    final cached = await PageDataCache.getJsonList(CacheKeys.publicacoes);
    if (cached != null) {
      return cached.map(PublicacaoModel.fromMap).toList();
    }
  }

  final response = await getPublicacoes();
  final list = jsonDecode(response.body) as List;
  final maps = list
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
  await PageDataCache.setJsonList(CacheKeys.publicacoes, maps);
  return maps.map(PublicacaoModel.fromMap).toList();
}

Future<void> excluirPublicacao(String id) async {
  await deletePublicacao(id);
  await PageDataCache.invalidate(CacheKeys.publicacoes);
}
