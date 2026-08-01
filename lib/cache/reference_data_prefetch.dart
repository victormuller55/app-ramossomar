import 'dart:developer' as developer;

import 'package:app_ramos_candidatura/cache/reference_data_cache.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:app_ramos_candidatura/offline/connectivity_helper.dart';
import 'package:app_ramos_candidatura/pages/feed/feed_service.dart';
import 'package:app_ramos_candidatura/services/cidade_service.dart';
import 'package:app_ramos_candidatura/services/local_votacao_service.dart';

/// Baixa cidades, locais de votação e as 20 últimas publicações ao entrar
/// no app (quando online).
///
/// Usa as rotas `/todos` (carga completa) e grava locais **por cidade**
/// para o formulário offline ler direto. Publicações ficam na página 1
/// do feed para visualização offline.
class ReferenceDataPrefetch {
  ReferenceDataPrefetch._();

  static bool _emAndamento = false;
  static bool _forcarProximo = false;

  /// Marca o próximo [sincronizar] (ex.: pós-login) para forçar download
  /// com snackbar de progresso.
  static void agendarDownloadPosLogin() {
    _forcarProximo = true;
  }

  /// Atualiza o cache se houver internet. Não bloqueia a UI.
  static Future<void> sincronizar({
    bool forcar = false,
    bool mostrarProgresso = true,
  }) async {
    if (_emAndamento) return;
    _emAndamento = true;

    final forcarEfetivo = forcar || _forcarProximo;
    final progressoEfetivo = mostrarProgresso || _forcarProximo;
    _forcarProximo = false;

    try {
      if (!await temConexao()) return;

      final precisaRef = await ReferenceDataCache.precisaAtualizar();
      final precisaFeed = forcarEfetivo || await lerPublicacoesOffline() == null;

      if (!forcarEfetivo && !precisaRef && !precisaFeed) {
        return;
      }

      if (progressoEfetivo) {
        showToastProgress(
          message: 'Baixando recursos para uso offline do aplicativo...',
        );
      }

      if (forcarEfetivo || precisaRef) {
        if (progressoEfetivo) {
          showToastProgress(
            message: 'Baixando cidades para uso offline... (1/3)',
          );
        }
        final cidades = await listarTodasCidades();
        await ReferenceDataCache.setCidades(cidades);

        if (progressoEfetivo) {
          showToastProgress(
            message: 'Baixando locais de votação para uso offline... (2/3)',
          );
        }
        final locais = await listarTodosLocaisVotacao();

        if (progressoEfetivo) {
          showToastProgress(message: 'Salvando recursos offline no aparelho...');
        }
        await ReferenceDataCache.setTodosLocais(locais);

        final locaisAtivos = locais.where((l) => l.ativo != false).length;
        developer.log(
          'Referência offline atualizada: ${cidades.length} cidades, $locaisAtivos locais',
          name: 'ReferenceDataPrefetch',
        );
      }

      if (forcarEfetivo || precisaFeed) {
        if (progressoEfetivo) {
          showToastProgress(
            message: 'Baixando publicações para uso offline... (3/3)',
          );
        }
        final feed = await listarPublicacoes(forceRefresh: true, pagina: 1);
        developer.log(
          'Feed offline atualizado: ${feed.itens.length} publicações',
          name: 'ReferenceDataPrefetch',
        );
      }

      if (progressoEfetivo) {
        showToastSuccess(message: 'Recursos offline prontos para uso');
      }
    } catch (e, st) {
      developer.log(
        'Falha ao pré-carregar recursos offline',
        name: 'ReferenceDataPrefetch',
        error: e,
        stackTrace: st,
      );
      if (progressoEfetivo) {
        hideToastProgress();
        showToastWarning(
          message:
              'Não foi possível baixar os recursos offline. Tente novamente com internet.',
        );
      }
    } finally {
      _emAndamento = false;
    }
  }
}
