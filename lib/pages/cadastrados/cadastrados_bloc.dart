import 'package:bloc/bloc.dart';
import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_event.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_service.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_state.dart';

class CadastradosBloc extends Bloc<CadastradosEvent, CadastradosState> {
  CadastradosBloc() : super(CadastradosInitialState()) {
    on<CadastradosLoadEvent>(_carregar);
    on<CadastradosDeleteEvent>(_excluir);
  }

  Future<void> _carregar(
    CadastradosLoadEvent event,
    Emitter<CadastradosState> emit,
  ) async {
    emit(CadastradosLoadingState());
    try {
      final usuario = await getUsuarioLogado();
      final apoiadores = await listarApoiadores(forceRefresh: event.forceRefresh);
      emit(CadastradosSuccessState(apoiadores: apoiadores, usuario: usuario));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastradosErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _excluir(
    CadastradosDeleteEvent event,
    Emitter<CadastradosState> emit,
  ) async {
    emit(CadastradosLoadingState());
    try {
      await excluirApoiador(event.id);
      emit(CadastradosDeleteSuccessState());

      final usuario = await getUsuarioLogado();
      final apoiadores = await listarApoiadores(forceRefresh: true);
      emit(CadastradosSuccessState(apoiadores: apoiadores, usuario: usuario));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastradosErrorState(errorModel: errorModelFromException(e)));
    }
  }
}
