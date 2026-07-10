import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';

const String _keyToken = 'auth_token';
const String _keyUsuario = 'usuario_logado';
const String _keyAuthDay = 'auth_saved_day';

String _todayKey() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

Future<bool> _isSessaoExpirada(SharedPreferences prefs) async {
  final savedDay = prefs.getString(_keyAuthDay);
  if (savedDay == null || savedDay.isEmpty) return true;
  return savedDay != _todayKey();
}

Future<void> _clearSessao(SharedPreferences prefs) async {
  await prefs.remove(_keyToken);
  await prefs.remove(_keyUsuario);
  await prefs.remove(_keyAuthDay);
  await PageDataCache.clearAll();
}

Future<bool> _ensureSessaoAtiva() async {
  final prefs = await SharedPreferences.getInstance();
  if (!await _isSessaoExpirada(prefs)) return true;

  if (prefs.containsKey(_keyToken) || prefs.containsKey(_keyUsuario)) {
    await _clearSessao(prefs);
  }
  return false;
}

Future<bool> hasSessaoValida() async {
  if (!await _ensureSessaoAtiva()) return false;

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(_keyToken);
  if (token == null || token.isEmpty) return false;

  final usuarioJson = prefs.getString(_keyUsuario);
  return usuarioJson != null && usuarioJson.isNotEmpty;
}

Future<String?> getToken() async {
  if (!await _ensureSessaoAtiva()) return null;

  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyToken);
}

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyToken, token);
  await prefs.setString(_keyAuthDay, _todayKey());
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await _clearSessao(prefs);
}

Future<Map<String, String>> getAuthHeaders() async {
  final token = await getToken();
  if (token == null || token.isEmpty) return {};
  return {'Authorization': 'Bearer $token'};
}

Future<void> saveUsuarioLogado(UsuarioModel usuario) async {
  final prefs = await SharedPreferences.getInstance();
  final data = usuario.toMap()..remove('token');
  await prefs.setString(_keyUsuario, jsonEncode(data));
}

Future<UsuarioModel?> getUsuarioLogado() async {
  if (!await _ensureSessaoAtiva()) return null;

  final prefs = await SharedPreferences.getInstance();
  final jsonStr = prefs.getString(_keyUsuario);
  if (jsonStr == null || jsonStr.isEmpty) return null;
  try {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return UsuarioModel.fromMap(map);
  } catch (_) {
    return null;
  }
}

Future<String?> getTipoUsuarioLogado() async {
  final usuario = await getUsuarioLogado();
  return usuario?.tipo;
}

Future<bool> isAdminLogado() async {
  final usuario = await getUsuarioLogado();
  return usuario?.isAdmin ?? false;
}

Future<bool> isLiderLogado() async {
  final usuario = await getUsuarioLogado();
  return usuario?.isLider ?? false;
}
