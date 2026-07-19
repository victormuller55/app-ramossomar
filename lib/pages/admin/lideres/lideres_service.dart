import 'dart:convert';

import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_service.dart';
import 'package:app_ramos_candidatura/services/usuario_service.dart';

Future<List<UsuarioModel>> listarLideres({bool forceRefresh = false}) async {
  List<UsuarioModel> lideres;

  if (!forceRefresh) {
    final cached = await PageDataCache.getJsonList(CacheKeys.usuarios);
    if (cached != null) {
      lideres = cached.map(UsuarioModel.fromMap).toList();
      await _preencherTotalApoiadores(lideres, forceRefresh: false);
      return lideres;
    }
  }

  final response = await getUsuarios(perfil: TipoUsuario.lider);
  final list = jsonDecode(response.body) as List;
  final maps = list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  await PageDataCache.setJsonList(CacheKeys.usuarios, maps);
  lideres = maps.map(UsuarioModel.fromMap).toList();
  await _preencherTotalApoiadores(lideres, forceRefresh: forceRefresh);
  return lideres;
}

Future<void> _preencherTotalApoiadores(
  List<UsuarioModel> lideres, {
  required bool forceRefresh,
}) async {
  try {
    final apoiadores = await listarApoiadores(forceRefresh: forceRefresh);
    final counts = <String, int>{};
    for (final apoiador in apoiadores) {
      final id = apoiador.idLider;
      if (id == null || id.isEmpty) continue;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    for (final lider in lideres) {
      final id = lider.id;
      if (id == null || id.isEmpty) continue;
      lider.totalApoiadores = counts[id] ?? 0;
    }
  } catch (_) {
    // Mantém totalApoiadores da API (se houver) quando a agregação falhar.
  }
}

Future<void> excluirLider(String id) async {
  await deleteUsuario(id);
  await PageDataCache.invalidate(CacheKeys.usuarios);
}
