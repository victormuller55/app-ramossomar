import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/models/publicacao_model.dart';
import 'package:app_ramos_candidatura/offline/connectivity_helper.dart';
import 'package:app_ramos_candidatura/pages/feed/feed_event.dart';
import 'package:app_ramos_candidatura/pages/feed/feed_service.dart';
import 'package:app_ramos_candidatura/pages/feed/feed_state.dart';
import 'package:bloc/bloc.dart';
import 'package:muller_package/muller_package.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc() : super(FeedInitialState()) {
    on<FeedLoadEvent>(_carregar);
    on<FeedLoadMoreEvent>(_carregarMais);
    on<FeedDeleteEvent>(_apagar);
  }

  Future<void> _carregar(
    FeedLoadEvent event,
    Emitter<FeedState> emit,
  ) async {
    final manterLista = state is FeedSuccessState &&
        (state as FeedSuccessState).publicacoes.isNotEmpty;

    if (!manterLista) {
      emit(FeedLoadingState());
    }

    try {
      final online = await temConexao();

      if (!online) {
        final offline = await _emitirOffline(emit);
        if (!offline) {
          emit(
            FeedErrorState(
              errorModel: ErrorModel(
                mensagem:
                    'Sem conexão e nenhuma publicação salva neste aparelho.',
                erro: 'OFFLINE_SEM_CACHE',
                tipo: '0',
              ),
            ),
          );
        }
        return;
      }

      final pagina = await listarPublicacoes(
        forceRefresh: event.forceRefresh,
        pagina: 1,
      );
      emit(
        FeedSuccessState(
          publicacoes: pagina.itens,
          numPagina: pagina.numPagina,
          maxPaginas: pagina.maxPaginas,
          maxItens: pagina.maxItens,
          offline: false,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;

      final offline = await _emitirOffline(emit);
      if (offline) return;

      emit(FeedErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<bool> _emitirOffline(Emitter<FeedState> emit) async {
    final cache = await lerPublicacoesOffline();
    if (cache == null) return false;

    emit(
      FeedSuccessState(
        publicacoes: cache.itens,
        numPagina: 1,
        maxPaginas: 1,
        maxItens: cache.itens.length,
        offline: true,
      ),
    );
    return true;
  }

  Future<void> _carregarMais(
    FeedLoadMoreEvent event,
    Emitter<FeedState> emit,
  ) async {
    final atual = state;
    if (atual is! FeedSuccessState) return;
    if (atual.offline || atual.loadingMore || !atual.temProximaPagina) return;
    if (!await temConexao()) return;

    emit(atual.copyWith(loadingMore: true));
    try {
      final pagina = await listarPublicacoes(
        forceRefresh: true,
        pagina: atual.numPagina + 1,
      );
      final acumulado = <PublicacaoModel>[
        ...atual.publicacoes,
        ...pagina.itens,
      ];
      emit(
        atual.copyWith(
          publicacoes: acumulado,
          numPagina: pagina.numPagina,
          maxPaginas: pagina.maxPaginas,
          maxItens: pagina.maxItens,
          loadingMore: false,
          offline: false,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(atual.copyWith(loadingMore: false));
    }
  }

  Future<void> _apagar(
    FeedDeleteEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (!await temConexao()) {
      emit(
        FeedErrorState(
          errorModel: ErrorModel(
            mensagem: 'Sem conexão. Não é possível apagar publicações offline.',
            erro: 'OFFLINE',
            tipo: '0',
          ),
        ),
      );
      return;
    }

    emit(FeedLoadingState());
    try {
      await excluirPublicacao(event.id);
      final pagina = await listarPublicacoes(forceRefresh: true, pagina: 1);
      emit(
        FeedSuccessState(
          publicacoes: pagina.itens,
          numPagina: pagina.numPagina,
          maxPaginas: pagina.maxPaginas,
          maxItens: pagina.maxItens,
          offline: false,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(FeedErrorState(errorModel: errorModelFromException(e)));
    }
  }
}
