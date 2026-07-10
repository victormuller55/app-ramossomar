import 'package:bloc/bloc.dart';
import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/cadastro_lider/cadastro_lider_event.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/cadastro_lider/cadastro_lider_service.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/cadastro_lider/cadastro_lider_state.dart';

class CadastroLiderBloc extends Bloc<CadastroLiderEvent, CadastroLiderState> {
  CadastroLiderBloc() : super(CadastroLiderInitialState()) {
    on<CadastroLiderSaveEvent>(_salvar);
  }

  Future<void> _salvar(
    CadastroLiderSaveEvent event,
    Emitter<CadastroLiderState> emit,
  ) async {
    emit(CadastroLiderLoadingState());
    try {
      await salvarLider(event.lider);
      emit(CadastroLiderSuccessState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroLiderErrorState(errorModel: errorModelFromException(e)));
    }
  }
}
