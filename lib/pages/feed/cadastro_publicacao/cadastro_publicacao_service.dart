import 'dart:convert';

import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/models/publicacao_model.dart';
import 'package:app_ramos_candidatura/services/publicacao_service.dart';

Future<PublicacaoModel> criarPublicacao(PublicacaoModel publicacao) async {
  final response = await postPublicacao(publicacao.toJsonCadastro());
  await PageDataCache.invalidate(CacheKeys.publicacoes);

  if (response.body.isEmpty) return publicacao;
  return PublicacaoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}
