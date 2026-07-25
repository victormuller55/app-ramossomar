import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_ramos_candidatura/app_config/app_platform.dart';
import 'package:app_ramos_candidatura/app_config/const/app_api_config.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';

const String _keyToken = 'auth_token';
const String _keyUsuario = 'usuario_logado';
const String _keyAuthDay = 'auth_saved_day';
const String _keyDeviceId = 'device_id';

const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

String _todayKey() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

String _newDeviceId() {
  final random = Random.secure();
  String hex(int bytes) => List.generate(
        bytes,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
  return '${hex(4)}-${hex(2)}-${hex(2)}-${hex(2)}-${hex(6)}';
}

Future<String> getDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  final existing = prefs.getString(_keyDeviceId);
  if (existing != null && existing.isNotEmpty) return existing;

  final created = _newDeviceId();
  await prefs.setString(_keyDeviceId, created);
  return created;
}

Future<bool> _isSessaoExpirada(SharedPreferences prefs) async {
  final savedDay = prefs.getString(_keyAuthDay);
  if (savedDay == null || savedDay.isEmpty) return true;
  return savedDay != _todayKey();
}

Future<void> _clearSessao(SharedPreferences prefs) async {
  await _secureStorage.delete(key: _keyToken);
  await prefs.remove(_keyToken);
  await prefs.remove(_keyUsuario);
  await prefs.remove(_keyAuthDay);
  await PageDataCache.clearAll();
}

Future<bool> _ensureSessaoAtiva() async {
  final prefs = await SharedPreferences.getInstance();
  if (!await _isSessaoExpirada(prefs)) return true;

  final hasSecureToken = (await _secureStorage.read(key: _keyToken))?.isNotEmpty == true;
  if (hasSecureToken || prefs.containsKey(_keyToken) || prefs.containsKey(_keyUsuario)) {
    await _clearSessao(prefs);
  }
  return false;
}

Future<bool> hasSessaoValida() async {
  if (!await _ensureSessaoAtiva()) return false;

  final token = await getToken();
  if (token == null || token.isEmpty) return false;

  final prefs = await SharedPreferences.getInstance();
  final usuarioJson = prefs.getString(_keyUsuario);
  return usuarioJson != null && usuarioJson.isNotEmpty;
}

Future<String?> getToken() async {
  if (!await _ensureSessaoAtiva()) return null;

  final secureToken = await _secureStorage.read(key: _keyToken);
  if (secureToken != null && secureToken.isNotEmpty) return secureToken;

  // Migração: token antigo em SharedPreferences → secure storage.
  final prefs = await SharedPreferences.getInstance();
  final legacy = prefs.getString(_keyToken);
  if (legacy == null || legacy.isEmpty) return null;

  await _secureStorage.write(key: _keyToken, value: legacy);
  await prefs.remove(_keyToken);
  return legacy;
}

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await _secureStorage.write(key: _keyToken, value: token);
  await prefs.remove(_keyToken);
  await prefs.setString(_keyAuthDay, _todayKey());
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await _clearSessao(prefs);
}

/// Headers obrigatórios da API (client + Accept + telemetria) e Bearer se logado.
Future<Map<String, String>> getAuthHeaders() async {
  final headers = <String, String>{
    'X-Client-Id': AppApiConfig.clientId,
    'X-Client-Secret': AppApiConfig.clientSecret,
    'Accept': 'application/json',
    'X-App-Version': AppApiConfig.appVersion,
    'X-Platform': isIOSPlatform ? 'ios' : 'android',
    'X-Device-Id': await getDeviceId(),
  };

  final token = await getToken();
  if (token != null && token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }
  return headers;
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
