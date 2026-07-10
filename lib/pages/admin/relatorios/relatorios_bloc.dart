import 'package:bloc/bloc.dart';
import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/pages/admin/relatorios/relatorios_event.dart';
import 'package:app_ramos_candidatura/pages/admin/relatorios/relatorios_service.dart';
import 'package:app_ramos_candidatura/pages/admin/relatorios/relatorios_state.dart';

class RelatoriosBloc extends Bloc<RelatoriosEvent, RelatoriosState> {
  RelatoriosBloc() : super(RelatoriosInitialState()) {
    on<RelatoriosExportEvent>(_exportar);
  }

  Future<void> _exportar(
    RelatoriosExportEvent event,
    Emitter<RelatoriosState> emit,
  ) async {
    emit(RelatoriosLoadingState());
    try {
      final path = await exportarRelatorioApoiadores(
        formato: event.formato,
        cidade: event.cidade,
        intencaoVoto: event.intencaoVoto,
      );
      emit(RelatoriosSuccessState(filePath: path, formato: event.formato));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(RelatoriosErrorState(errorModel: errorModelFromException(e)));
    }
  }
}
