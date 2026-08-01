import 'dart:convert';

import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/models/apoiador_model.dart';
import 'package:app_ramos_candidatura/models/paginacao_model.dart';
import 'package:app_ramos_candidatura/services/apoiador_service.dart';

Future<PaginacaoModel<ApoiadorModel>> listarApoiadores({
  bool forceRefresh = false,
  int pagina = 1,
  String? nome,
}) async {
  final busca = nome?.trim();
  final semFiltro = busca == null || busca.isEmpty;
  final podeUsarCache = !forceRefresh && pagina == 1 && semFiltro;

  if (podeUsarCache) {
    final cached = await PageDataCache.getJsonMap(CacheKeys.apoiadores);
    if (cached != null) {
      return PaginacaoModel.fromMap(cached, ApoiadorModel.fromMap);
    }
  }

  final response = await getApoiadores(pagina: pagina, nome: busca);
  final decoded = jsonDecode(response.body);
  if (decoded is! Map) {
    throw FormatException('Resposta paginada inválida de apoiadores');
  }

  final map = Map<String, dynamic>.from(decoded);
  final paginacao = PaginacaoModel.fromMap(map, ApoiadorModel.fromMap);

  if (pagina == 1 && semFiltro) {
    await PageDataCache.setJsonMap(
      CacheKeys.apoiadores,
      paginacao.toCacheMap((item) => item.toMap()),
    );
  }

  return paginacao;
}

Future<void> excluirApoiador(String id) async {
  await deleteApoiador(id);
  await PageDataCache.invalidate(CacheKeys.apoiadores);
}
