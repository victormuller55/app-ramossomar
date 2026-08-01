import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/offline/connectivity_helper.dart';
import 'package:app_ramos_candidatura/offline/offline_apoiador_queue.dart';
import 'package:app_ramos_candidatura/offline/offline_sync_service.dart';
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
      final isEdit = apoiador.id != null && apoiador.id!.isNotEmpty;
      final online = await temConexao();

      if (isEdit && !online) {
        emit(CadastroPessoaErrorState(errorModel: _erroEdicaoOffline));
        return;
      }

      final idLider = await _resolverIdLider(apoiador.idLider);
      if (idLider == null) {
        emit(CadastroPessoaErrorState(errorModel: _erroLiderInvalido));
        return;
      }

      apoiador.idLider = idLider;

      if (!online) {
        await OfflineApoiadorQueue.adicionar(apoiador);
        OfflineSyncService.instance.pendentesCount.value =
            await OfflineApoiadorQueue.count();
        emit(CadastroPessoaSuccessState(salvoOffline: true));
        return;
      }

      await salvarApoiador(apoiador);
      emit(CadastroPessoaSuccessState());
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;

      // Falha de rede no meio do cadastro online → salva offline (só criação).
      final isEdit = event.apoiador.id != null && event.apoiador.id!.isNotEmpty;
      if (!isEdit && _ehErroRede(e)) {
        try {
          final idLider = await _resolverIdLider(event.apoiador.idLider);
          if (idLider != null) {
            event.apoiador.idLider = idLider;
            await OfflineApoiadorQueue.adicionar(event.apoiador);
            OfflineSyncService.instance.pendentesCount.value =
                await OfflineApoiadorQueue.count();
            emit(CadastroPessoaSuccessState(salvoOffline: true));
            return;
          }
        } catch (_) {}
      }

      emit(CadastroPessoaErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<String?> _resolverIdLider(String? idLiderAtual) async {
    if (idLiderAtual != null && idLiderAtual.isNotEmpty) return idLiderAtual;

    final idLider = (await getUsuarioLogado())?.id;
    if (idLider == null || idLider.isEmpty) return null;
    return idLider;
  }

  bool _ehErroRede(Object e) {
    if (e is! ApiException) return true;
    return e.response.statusCode == 0;
  }

  static final ErrorModel _erroLiderInvalido = ErrorModel(
    mensagem: 'Não foi possível identificar o líder logado.',
    erro: 'USUARIO_INVALIDO',
    tipo: '0',
  );

  static final ErrorModel _erroEdicaoOffline = ErrorModel(
    mensagem: 'É necessário conexão com a internet para editar um cadastro.',
    erro: 'OFFLINE',
    tipo: '0',
  );
}
