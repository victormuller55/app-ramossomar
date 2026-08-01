import 'dart:convert';

import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/models/paginacao_model.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/services/usuario_service.dart';

Future<PaginacaoModel<UsuarioModel>> listarLideres({
  bool forceRefresh = false,
  int pagina = 1,
  String? nome,
  bool? ativo,
}) async {
  final busca = nome?.trim();
  final semFiltro = (busca == null || busca.isEmpty) && ativo == null;
  final podeUsarCache = !forceRefresh && pagina == 1 && semFiltro;

  if (podeUsarCache) {
    final cached = await PageDataCache.getJsonMap(CacheKeys.usuarios);
    if (cached != null) {
      return PaginacaoModel.fromMap(cached, UsuarioModel.fromMap);
    }
  }

  final response = await getUsuarios(
    perfil: TipoUsuario.lider,
    pagina: pagina,
    nome: busca,
    ativo: ativo,
  );
  final decoded = jsonDecode(response.body);
  if (decoded is! Map) {
    throw FormatException('Resposta paginada inválida de usuários');
  }

  final map = Map<String, dynamic>.from(decoded);
  final paginacao = PaginacaoModel.fromMap(map, UsuarioModel.fromMap);

  if (pagina == 1 && semFiltro) {
    await PageDataCache.setJsonMap(
      CacheKeys.usuarios,
      paginacao.toCacheMap((item) => item.toMap()),
    );
  }

  return paginacao;
}

Future<void> excluirLider(String id) async {
  await deleteUsuario(id);
  await PageDataCache.invalidate(CacheKeys.usuarios);
}
