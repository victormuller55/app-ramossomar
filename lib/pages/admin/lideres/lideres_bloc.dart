import 'package:bloc/bloc.dart';
import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/lideres_event.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/lideres_service.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/lideres_state.dart';

class LideresBloc extends Bloc<LideresEvent, LideresState> {
  LideresBloc() : super(LideresInitialState()) {
    on<LideresLoadEvent>(_carregar);
    on<LideresDeleteEvent>(_excluir);
  }

  Future<void> _carregar(
    LideresLoadEvent event,
    Emitter<LideresState> emit,
  ) async {
    emit(LideresLoadingState());
    try {
      final lideres = await listarLideres(forceRefresh: event.forceRefresh);
      emit(LideresSuccessState(lideres: lideres));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(LideresErrorState(errorModel: errorModelFromException(e)));
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

      final lideres = await listarLideres(forceRefresh: true);
      emit(LideresSuccessState(lideres: lideres));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(LideresErrorState(errorModel: errorModelFromException(e)));
    }
  }
}
