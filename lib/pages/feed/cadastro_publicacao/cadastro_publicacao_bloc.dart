import 'package:bloc/bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/pages/feed/cadastro_publicacao/cadastro_publicacao_event.dart';
import 'package:app_ramos_candidatura/pages/feed/cadastro_publicacao/cadastro_publicacao_service.dart';
import 'package:app_ramos_candidatura/pages/feed/cadastro_publicacao/cadastro_publicacao_state.dart';

class CadastroPublicacaoBloc extends Bloc<CadastroPublicacaoEvent, CadastroPublicacaoState> {
  CadastroPublicacaoBloc() : super(CadastroPublicacaoInitialState()) {
    on<CadastroPublicacaoSaveEvent>(_salvar);
  }

  Future<void> _salvar(
    CadastroPublicacaoSaveEvent event,
    Emitter<CadastroPublicacaoState> emit,
  ) async {
    emit(CadastroPublicacaoLoadingState());
    try {
      final idAutor = await _resolverIdAutor();
      if (idAutor == null) {
        emit(CadastroPublicacaoErrorState(errorModel: _erroAutorInvalido));
        return;
      }

      event.publicacao.idAutor = idAutor;
      await criarPublicacao(event.publicacao, imagens: event.imagens);
      emit(CadastroPublicacaoSuccessState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(CadastroPublicacaoErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<String?> _resolverIdAutor() async {
    final idAutor = (await getUsuarioLogado())?.id;
    if (idAutor == null || idAutor.isEmpty) return null;
    return idAutor;
  }

  static final ErrorModel _erroAutorInvalido = ErrorModel(
    mensagem: 'Não foi possível identificar o autor logado.',
    erro: 'USUARIO_INVALIDO',
    tipo: '0',
  );
}
