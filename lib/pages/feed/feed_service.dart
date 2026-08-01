import 'dart:convert';

import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/models/paginacao_model.dart';
import 'package:app_ramos_candidatura/models/publicacao_model.dart';
import 'package:app_ramos_candidatura/services/publicacao_service.dart';

/// Última página 1 salva no aparelho (mesmo com TTL vencido).
Future<PaginacaoModel<PublicacaoModel>?> lerPublicacoesOffline() async {
  final cached = await PageDataCache.getJsonMap(
    CacheKeys.publicacoes,
    allowStale: true,
  );
  if (cached == null) return null;
  return PaginacaoModel.fromMap(cached, PublicacaoModel.fromMap);
}

Future<void> _salvarPublicacoesOffline(
  PaginacaoModel<PublicacaoModel> paginacao,
) async {
  await PageDataCache.setJsonMap(
    CacheKeys.publicacoes,
    paginacao.toCacheMap((item) => item.toMap()),
  );
}

Future<PaginacaoModel<PublicacaoModel>> listarPublicacoes({
  bool forceRefresh = false,
  int pagina = 1,
}) async {
  final podeUsarCacheFresco = !forceRefresh && pagina == 1;

  if (podeUsarCacheFresco) {
    final cached = await PageDataCache.getJsonMap(CacheKeys.publicacoes);
    if (cached != null) {
      return PaginacaoModel.fromMap(cached, PublicacaoModel.fromMap);
    }
  }

  final response = await getPublicacoes(pagina: pagina);
  final decoded = jsonDecode(response.body);
  if (decoded is! Map) {
    throw FormatException('Resposta paginada inválida de publicações');
  }

  final map = Map<String, dynamic>.from(decoded);
  final paginacao = PaginacaoModel.fromMap(map, PublicacaoModel.fromMap);

  // Sempre persiste a página 1 para visualização offline.
  if (pagina == 1) {
    await _salvarPublicacoesOffline(paginacao);
  }

  return paginacao;
}

Future<void> excluirPublicacao(String id) async {
  await deletePublicacao(id);
  // A lista offline é regravada no próximo listarPublicacoes(pagina: 1).
}
