import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Cache local das listas (cadastrados, feed, líderes).
///
/// - TTL: 5 minutos.
/// - Enquanto o usuário só visualiza, a tela usa o cache (sem nova chamada).
/// - Recarrega da API com [forceRefresh] no pull-to-refresh, ou após
///   cadastro/edição/exclusão (invalidate + reload).
class PageDataCache {
  PageDataCache._();

  static const Duration ttl = Duration(minutes: 5);
  static const _prefix = 'page_cache_';
  static const _tsSuffix = '_ts';

  static Future<List<Map<String, dynamic>>?> getJsonList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('$_prefix$key$_tsSuffix');
    if (timestamp == null || _isExpired(timestamp)) {
      await invalidate(key);
      return null;
    }

    final raw = prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return null;

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

  static bool _isExpired(int timestampMs) {
    final age = DateTime.now().millisecondsSinceEpoch - timestampMs;
    return age > ttl.inMilliseconds;
  }
}
