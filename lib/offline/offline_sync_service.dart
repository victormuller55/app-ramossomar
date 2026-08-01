import 'dart:async';
import 'dart:developer' as developer;

import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/offline/connectivity_helper.dart';
import 'package:app_ramos_candidatura/offline/offline_apoiador_queue.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastro_pessoa/cadastro_pessoa_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:muller_package/muller_package.dart';

/// Sincroniza a fila local de apoiadores quando houver internet.
class OfflineSyncService {
  OfflineSyncService._();

  static final OfflineSyncService instance = OfflineSyncService._();

  final ValueNotifier<int> pendentesCount = ValueNotifier<int>(0);
  final ValueNotifier<bool> syncing = ValueNotifier<bool>(false);
  final ValueNotifier<int> syncVersion = ValueNotifier<int>(0);

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _started = false;

  /// Future da sincronização em andamento (mutex). Callers concorrentes aguardam
  /// o mesmo Future em vez de disparar POSTs duplicados.
  Future<int>? _syncFuture;
  bool _notifyUiPending = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _atualizarContagem();
    _subscription = onConnectivityChanged().listen((results) {
      if (connectivityResultsOnline(results)) {
        unawaited(sincronizar());
      }
    });
    if (await temConexao()) {
      unawaited(sincronizar());
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _started = false;
  }

  Future<void> _atualizarContagem() async {
    pendentesCount.value = await OfflineApoiadorQueue.count();
  }

  /// Envia itens da fila um a um. Retorna quantos foram enviados com sucesso.
  ///
  /// [notifyUi]: quando true (padrão), incrementa [syncVersion] para telas
  /// recarregarem. Use false quando o caller já vai atualizar a lista.
  Future<int> sincronizar({bool notifyUi = true}) async {
    if (notifyUi) _notifyUiPending = true;

    final emAndamento = _syncFuture;
    if (emAndamento != null) {
      final enviados = await emAndamento;
      // Se a fila ainda tem itens após o sync anterior (itens novos ou gap
      // entre fim do loop e liberação do mutex), processa de novo.
      if (_syncFuture == null && await OfflineApoiadorQueue.count() > 0) {
        return enviados + await sincronizar(notifyUi: false);
      }
      return enviados;
    }

    // Lock síncrono: em Dart não há preempção entre o check e esta atribuição.
    final completer = Completer<int>();
    _syncFuture = completer.future;
    syncing.value = true;

    var totalEnviados = 0;

    try {
      totalEnviados = await _processarFila();

      if (totalEnviados > 0) {
        await PageDataCache.invalidate(CacheKeys.apoiadores);
        if (_notifyUiPending) {
          _notifyUiPending = false;
          syncVersion.value = syncVersion.value + 1;
        }
      } else {
        _notifyUiPending = false;
      }

      completer.complete(totalEnviados);
      return totalEnviados;
    } catch (e, st) {
      _notifyUiPending = false;
      if (!completer.isCompleted) completer.completeError(e, st);
      rethrow;
    } finally {
      await _atualizarContagem();
      syncing.value = false;
      _syncFuture = null;
    }
  }

  Future<int> _processarFila() async {
    if (!await temConexao()) return 0;
    if (!await hasSessaoValida()) return 0;

    final fila = await OfflineApoiadorQueue.listar();
    if (fila.isEmpty) return 0;

    var enviados = 0;

    for (final item in List<OfflineApoiadorItem>.from(fila)) {
      if (!await temConexao()) break;
      if (!await hasSessaoValida()) break;

      try {
        await criarApoiador(item.apoiador);
        await OfflineApoiadorQueue.remover(item.localId);
        enviados++;
      } catch (e) {
        if (await tratarSessaoExpirada(e)) return enviados;

        if (_ehErroRede(e)) {
          developer.log(
            'Sync offline interrompido por falha de rede',
            name: 'OfflineSync',
            error: e,
          );
          break;
        }

        // Erro de negócio (ex.: CPF duplicado) — remove para evitar loop.
        developer.log(
          'Item offline descartado por erro de negócio: ${item.localId}',
          name: 'OfflineSync',
          error: e,
        );
        await OfflineApoiadorQueue.remover(item.localId);
      }
    }

    return enviados;
  }

  bool _ehErroRede(Object e) {
    if (e is! ApiException) return true;
    final status = e.response.statusCode;
    if (status == 0) return true;
    final body = e.response.body.toString().toLowerCase();
    return body.contains('socket') ||
        body.contains('failed host') ||
        body.contains('network') ||
        body.contains('connection');
  }
}
