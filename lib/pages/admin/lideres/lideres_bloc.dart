import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/lideres_event.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/lideres_service.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/lideres_state.dart';
import 'package:bloc/bloc.dart';

class LideresBloc extends Bloc<LideresEvent, LideresState> {
  LideresBloc() : super(LideresInitialState()) {
    on<LideresLoadEvent>(_carregar);
    on<LideresLoadMoreEvent>(_carregarMais);
    on<LideresDeleteEvent>(_excluir);
  }

  String? _nomeBusca;
  bool? _filtroAtivo;

  Future<void> _carregar(
    LideresLoadEvent event,
    Emitter<LideresState> emit,
  ) async {
    _nomeBusca = event.nome?.trim();
    if (_nomeBusca != null && _nomeBusca!.isEmpty) _nomeBusca = null;
    _filtroAtivo = event.ativo;

    final manterLista = state is LideresSuccessState &&
        (state as LideresSuccessState).lideres.isNotEmpty;

    if (!manterLista) {
      emit(LideresLoadingState());
    }

    try {
      final pagina = await listarLideres(
        forceRefresh: event.forceRefresh,
        pagina: 1,
        nome: _nomeBusca,
        ativo: _filtroAtivo,
      );
      emit(
        LideresSuccessState(
          lideres: pagina.itens,
          numPagina: pagina.numPagina,
          maxPaginas: pagina.maxPaginas,
          maxItens: pagina.maxItens,
          nomeBusca: _nomeBusca,
          filtroAtivo: _filtroAtivo,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(LideresErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _carregarMais(
    LideresLoadMoreEvent event,
    Emitter<LideresState> emit,
  ) async {
    final atual = state;
    if (atual is! LideresSuccessState) return;
    if (atual.loadingMore || !atual.temProximaPagina) return;

    emit(atual.copyWith(loadingMore: true));
    try {
      final pagina = await listarLideres(
        forceRefresh: true,
        pagina: atual.numPagina + 1,
        nome: _nomeBusca,
        ativo: _filtroAtivo,
      );
      final acumulado = <UsuarioModel>[
        ...atual.lideres,
        ...pagina.itens,
      ];
      emit(
        atual.copyWith(
          lideres: acumulado,
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
    LideresDeleteEvent event,
    Emitter<LideresState> emit,
  ) async {
    emit(LideresLoadingState());
    try {
      await excluirLider(event.id);
      emit(LideresDeleteSuccessState());

      final pagina = await listarLideres(
        forceRefresh: true,
        pagina: 1,
        nome: _nomeBusca,
        ativo: _filtroAtivo,
      );
      emit(
        LideresSuccessState(
          lideres: pagina.itens,
          numPagina: pagina.numPagina,
          maxPaginas: pagina.maxPaginas,
          maxItens: pagina.maxItens,
          nomeBusca: _nomeBusca,
          filtroAtivo: _filtroAtivo,
        ),
      );
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(LideresErrorState(errorModel: errorModelFromException(e)));
    }
  }
}
