import 'dart:convert';

import 'package:app_ramos_candidatura/models/cidade_model.dart';
import 'package:app_ramos_candidatura/models/local_votacao_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache persistente de cidades e locais de votação para uso offline.
///
/// Locais ficam **por cidade** (`locais_<idCidade>`) para não estourar o
/// limite de tamanho do SharedPreferences.
class ReferenceDataCache {
  ReferenceDataCache._();

  static const Duration ttl = Duration(days: 7);
  static const _prefix = 'ref_cache_';
  static const _tsSuffix = '_ts';
  static const cidadesKey = 'cidades';
  static const locaisReadyKey = 'locais_ready';

  static String locaisKey(String idCidade) => 'locais_$idCidade';

  static Future<List<Map<String, dynamic>>?> _getJsonList(
    String key, {
    bool allowStale = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('$_prefix$key$_tsSuffix');
    final raw = prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return null;

    if (timestamp != null && _isExpired(timestamp) && !allowStale) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (_) {
      await invalidate(key);
      return null;
    }
  }

  static Future<void> setJsonList(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', jsonEncode(data));
    await prefs.setInt('$_prefix$key$_tsSuffix', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> invalidate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
    await prefs.remove('$_prefix$key$_tsSuffix');
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  static Future<bool> precisaAtualizar() async {
    final prefs = await SharedPreferences.getInstance();
    final cidadesTs = prefs.getInt('$_prefix$cidadesKey$_tsSuffix');
    final locaisTs = prefs.getInt('$_prefix$locaisReadyKey$_tsSuffix');
    if (cidadesTs == null || locaisTs == null) return true;
    return _isExpired(cidadesTs) || _isExpired(locaisTs);
  }

  static Future<void> marcarLocaisProntos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      '$_prefix$locaisReadyKey$_tsSuffix',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<List<CidadeModel>?> getCidades({bool allowStale = true}) async {
    final cached = await _getJsonList(cidadesKey, allowStale: allowStale);
    if (cached == null) return null;
    return cached.map(CidadeModel.fromMap).toList();
  }

  static Future<void> setCidades(List<CidadeModel> cidades) async {
    await setJsonList(cidadesKey, cidades.map(_cidadeCacheMap).toList());
  }

  /// Locais da cidade salvos no aparelho.
  static Future<List<LocalVotacaoModel>> getLocaisDaCidade(
    String idCidade, {
    bool allowStale = true,
  }) async {
    final id = idCidade.trim();
    if (id.isEmpty) return [];

    final cached = await _getJsonList(locaisKey(id), allowStale: allowStale);
    if (cached == null) return [];
    return cached.map(LocalVotacaoModel.fromMap).toList();
  }

  static Future<void> setLocaisDaCidade(
    String idCidade,
    List<LocalVotacaoModel> locais,
  ) async {
    final id = idCidade.trim();
    if (id.isEmpty) return;

    await setJsonList(
      locaisKey(id),
      locais.map((l) => _localCacheMap(l, idCidade: id)).toList(),
    );
  }

  /// Salva o mapa completo cidade → locais.
  static Future<void> setLocaisPorCidade(
    Map<String, List<LocalVotacaoModel>> porCidade,
  ) async {
    for (final entry in porCidade.entries) {
      await setLocaisDaCidade(entry.key, entry.value);
    }
    await marcarLocaisProntos();
  }

  /// Agrupa a lista completa de locais por cidade e persiste.
  static Future<void> setTodosLocais(List<LocalVotacaoModel> locais) async {
    final porCidade = <String, List<LocalVotacaoModel>>{};
    for (final local in locais) {
      if (local.ativo == false) continue;
      final id = (local.idCidade ?? '').trim();
      if (id.isEmpty) continue;
      (porCidade[id] ??= []).add(local);
    }
    await setLocaisPorCidade(porCidade);
  }

  static Map<String, dynamic> _cidadeCacheMap(CidadeModel c) {
    return {
      'id': c.id,
      'nome': c.nome,
      'uf': c.uf,
    };
  }

  static Map<String, dynamic> _localCacheMap(
    LocalVotacaoModel l, {
    required String idCidade,
  }) {
    return {
      'id': l.id,
      'nome': l.nome,
      'zona_eleitoral': l.zonaEleitoral,
      'id_cidade': idCidade,
      'nome_cidade': l.nomeCidade,
    };
  }

  static bool _isExpired(int timestampMs) {
    final age = DateTime.now().millisecondsSinceEpoch - timestampMs;
    return age > ttl.inMilliseconds;
  }
}
