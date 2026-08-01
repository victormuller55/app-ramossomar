import 'dart:convert';
import 'dart:math';

import 'package:app_ramos_candidatura/models/apoiador_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineApoiadorItem {
  final String localId;
  final ApoiadorModel apoiador;
  final int createdAt;

  OfflineApoiadorItem({
    required this.localId,
    required this.apoiador,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'localId': localId,
      'createdAt': createdAt,
      'payload': apoiador.toMap(),
    };
  }

  factory OfflineApoiadorItem.fromMap(Map<String, dynamic> map) {
    final payload = Map<String, dynamic>.from(map['payload'] as Map);
    final localId = map['localId']?.toString() ?? '';
    final apoiador = ApoiadorModel.fromMap(payload)..localId = localId;
    return OfflineApoiadorItem(
      localId: localId,
      apoiador: apoiador,
      createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
    );
  }

  ApoiadorModel toApoiadorPendente() {
    return ApoiadorModel.fromMap(apoiador.toMap())..localId = localId;
  }
}

class OfflineApoiadorQueue {
  OfflineApoiadorQueue._();

  static const _key = 'offline_apoiadores_queue';

  static String _gerarLocalId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return 'offline_${ts}_$rand';
  }

  static Future<List<OfflineApoiadorItem>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map(
            (item) => OfflineApoiadorItem.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      await prefs.remove(_key);
      return [];
    }
  }

  static Future<int> count() async {
    final items = await listar();
    return items.length;
  }

  static Future<OfflineApoiadorItem> adicionar(ApoiadorModel apoiador) async {
    final items = await listar();
    final localId = _gerarLocalId();
    final item = OfflineApoiadorItem(
      localId: localId,
      apoiador: ApoiadorModel.fromMap(apoiador.toMap())..localId = localId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    items.add(item);
    await _salvar(items);
    return item;
  }

  static Future<void> remover(String localId) async {
    final items = await listar();
    items.removeWhere((item) => item.localId == localId);
    await _salvar(items);
  }

  static Future<void> substituirTodos(List<OfflineApoiadorItem> items) async {
    await _salvar(items);
  }

  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _salvar(List<OfflineApoiadorItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_key, encoded);
  }
}
