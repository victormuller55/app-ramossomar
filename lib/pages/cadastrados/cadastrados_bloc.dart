import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/models/apoiador_model.dart';
import 'package:app_ramos_candidatura/offline/connectivity_helper.dart';
import 'package:app_ramos_candidatura/offline/offline_apoiador_queue.dart';
import 'package:app_ramos_candidatura/offline/offline_sync_service.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_event.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_service.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_state.dart';
import 'package:bloc/bloc.dart';
import 'package:muller_package/muller_package.dart';

class CadastradosBloc extends Bloc<CadastradosEvent, CadastradosState> {
  CadastradosBloc() : super(CadastradosInitialState()) {
    on<CadastradosLoadEvent>(_carregar);
    on<CadastradosLoadMoreEvent>(_carregarMais);
    on<CadastradosDeleteEvent>(_excluir);
  }

  String? _nomeBusca;

  Future<void> _carregar(
    CadastradosLoadEvent event,
    Emitter<CadastradosState> emit,
  ) async {
    _nomeBusca = event.nome?.trim();
    if (_nomeBusca != null && _nomeBusca!.isEmpty) _nomeBusca = null;

    final manterLista = state is CadastradosSuccessState &&
        (state as CadastradosSuccessState).apoiadores.isNotEmpty &&
        !(state as CadastradosSuccessState).offline;

    if (!manterLista) {
      emit(CadastradosLoadingState());
    }

    try {
      final usuario = await getUsuarioLogado();
      final online = await temConexao();

      if (!online) {
        final pendentes = await OfflineApoiadorQueue.listar();
        emit(
          CadastradosSuccessState(
            apoiadores: pendentes.map((e) => e.toApoiadorPendente()).toList(),
            usuario: usuario,
            offline: true,
            maxItens: pendentes.length,
            nomeBusca: _nomeBusca,
          ),
        );
        return;
      }

      await OfflineSyncService.instance.sincronizar(notifyUi: false);
      final pagina = await listarApoiadores(
        forceRefresh: event.forceRefresh,
        pagina: 1,
        nome: _nomeBusca,
      );
      emit(
        CadastradosSuccessState(
          apoiadores: pagina.itens,
          usuario: usuario,
          offline: false,
          numPagina: pagina.numPagina,
          maxPaginas: pagina.maxPaginas,
          maxItens: pagina.maxItens,
          nomeBusca: _nomeBusca,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;

      if (!await temConexao() || _ehErroRede(e)) {
        final usuario = await getUsuarioLogado();
        final pendentes = await OfflineApoiadorQueue.listar();
        emit(
          CadastradosSuccessState(
            apoiadores: pendentes.map((e) => e.toApoiadorPendente()).toList(),
            usuario: usuario,
            offline: true,
            maxItens: pendentes.length,
            nomeBusca: _nomeBusca,
          ),
        );
        return;
      }

      emit(CadastradosErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _carregarMais(
    CadastradosLoadMoreEvent event,
    Emitter<CadastradosState> emit,
  ) async {
    final atual = state;
    if (atual is! CadastradosSuccessState) return;
    if (atual.offline || atual.loadingMore || !atual.temProximaPagina) return;

    emit(atual.copyWith(loadingMore: true));
    try {
      final proxima = atual.numPagina + 1;
      final pagina = await listarApoiadores(
        forceRefresh: true,
        pagina: proxima,
        nome: _nomeBusca,
      );
      final acumulado = <ApoiadorModel>[
        ...atual.apoiadores,
        ...pagina.itens,
      ];
      emit(
        atual.copyWith(
          apoiadores: acumulado,
          numPagina: pagina.numPagina,
          maxPaginas: pagina.maxPaginas,
          maxItens: pagina.maxItens,
          loadingMore: false,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(atual.copyWith(loadingMore: false));
    }
  }

  Future<void> _excluir(
    CadastradosDeleteEvent event,
    Emitter<CadastradosState> emit,
  ) async {
    emit(CadastradosLoadingState());
    try {
      final localId = event.localId;
      if (localId != null && localId.isNotEmpty) {
        await OfflineApoiadorQueue.remover(localId);
        OfflineSyncService.instance.pendentesCount.value =
            await OfflineApoiadorQueue.count();
        emit(CadastradosDeleteSuccessState());

        final usuario = await getUsuarioLogado();
        final online = await temConexao();
        if (!online) {
          final pendentes = await OfflineApoiadorQueue.listar();
          emit(
            CadastradosSuccessState(
              apoiadores: pendentes.map((e) => e.toApoiadorPendente()).toList(),
              usuario: usuario,
              offline: true,
              maxItens: pendentes.length,
              nomeBusca: _nomeBusca,
            ),
          );
          return;
        }

        final pagina = await listarApoiadores(
          forceRefresh: true,
          pagina: 1,
          nome: _nomeBusca,
        );
        emit(
          CadastradosSuccessState(
            apoiadores: pagina.itens,
            usuario: usuario,
            offline: false,
            numPagina: pagina.numPagina,
            maxPaginas: pagina.maxPaginas,
            maxItens: pagina.maxItens,
            nomeBusca: _nomeBusca,
          ),
        );
        return;
      }

      final id = event.id;
      if (id == null || id.isEmpty) {
        emit(
          CadastradosErrorState(
            errorModel: ErrorModel(
              mensagem: 'Identificador do cadastro inválido.',
              erro: 'ID_INVALIDO',
              tipo: '0',
            ),
          ),
        );
        return;
      }

      await excluirApoiador(id);
      emit(CadastradosDeleteSuccessState());

      final usuario = await getUsuarioLogado();
      final pagina = await listarApoiadores(
        forceRefresh: true,
        pagina: 1,
        nome: _nomeBusca,
      );
      emit(
        CadastradosSuccessState(
          apoiadores: pagina.itens,
          usuario: usuario,
          offline: false,
          numPagina: pagina.numPagina,
          maxPaginas: pagina.maxPaginas,
          maxItens: pagina.maxItens,
          nomeBusca: _nomeBusca,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastradosErrorState(errorModel: errorModelFromException(e)));
    }
  }

  bool _ehErroRede(Object e) {
    return e.toString().contains('SocketException') ||
        e.toString().contains('ClientException') ||
        e.toString().contains('Failed host');
  }
}
