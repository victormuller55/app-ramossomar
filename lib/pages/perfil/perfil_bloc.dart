import 'package:bloc/bloc.dart';
import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/pages/perfil/perfil_event.dart';
import 'package:app_ramos_candidatura/pages/perfil/perfil_service.dart';
import 'package:app_ramos_candidatura/pages/perfil/perfil_state.dart';

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  PerfilBloc() : super(PerfilInitialState()) {
    on<PerfilLoadEvent>(_carregar);
    on<PerfilSaveEvent>(_salvar);
  }

  Future<void> _carregar(
    PerfilLoadEvent event,
    Emitter<PerfilState> emit,
  ) async {
    emit(PerfilLoadingState());
    try {
      final usuario = await carregarPerfil();
      emit(PerfilLoadedState(usuario: usuario));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(PerfilErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _salvar(
    PerfilSaveEvent event,
    Emitter<PerfilState> emit,
  ) async {
    emit(PerfilLoadingState());
    try {
      final usuario = await salvarPerfil(event.usuario);
      emit(PerfilSuccessState(usuario: usuario));
      emit(PerfilLoadedState(usuario: usuario));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(PerfilErrorState(errorModel: errorModelFromException(e)));
    }
  }
}
