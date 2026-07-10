import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastro_pessoa/cadastro_pessoa_event.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastro_pessoa/cadastro_pessoa_service.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastro_pessoa/cadastro_pessoa_state.dart';
import 'package:bloc/bloc.dart';
import 'package:muller_package/muller_package.dart';

class CadastroPessoaBloc extends Bloc<CadastroPessoaEvent, CadastroPessoaState> {
  CadastroPessoaBloc() : super(CadastroPessoaInitialState()) {
    on<CadastroPessoaSaveEvent>(_salvar);
  }

  Future<void> _salvar(CadastroPessoaSaveEvent event, Emitter<CadastroPessoaState> emit) async {
    emit(CadastroPessoaLoadingState());
    try {
      final apoiador = event.apoiador;
      final idLider = await _resolverIdLider(apoiador.idLider);
      if (idLider == null) {
        emit(CadastroPessoaErrorState(errorModel: _erroLiderInvalido));
        return;
      }

      apoiador.idLider = idLider;
      await salvarApoiador(apoiador);
      emit(CadastroPessoaSuccessState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroPessoaErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<String?> _resolverIdLider(String? idLiderAtual) async {
    if (idLiderAtual != null && idLiderAtual.isNotEmpty) return idLiderAtual;

    final idLider = (await getUsuarioLogado())?.id;
    if (idLider == null || idLider.isEmpty) return null;
    return idLider;
  }

  static final ErrorModel _erroLiderInvalido = ErrorModel(
    mensagem: 'Não foi possível identificar o líder logado.',
    erro: 'USUARIO_INVALIDO',
    tipo: '0',
  );
}
