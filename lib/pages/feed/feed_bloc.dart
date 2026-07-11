import 'package:bloc/bloc.dart';
import 'package:app_ramos_candidatura/function/service/api_error.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/pages/feed/feed_event.dart';
import 'package:app_ramos_candidatura/pages/feed/feed_service.dart';
import 'package:app_ramos_candidatura/pages/feed/feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc() : super(FeedInitialState()) {
    on<FeedLoadEvent>(_carregar);
    on<FeedDeleteEvent>(_apagar);
  }

  Future<void> _carregar(
    FeedLoadEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(FeedLoadingState());
    try {
      final publicacoes = await listarPublicacoes(forceRefresh: event.forceRefresh);
      emit(FeedSuccessState(publicacoes: publicacoes));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(FeedErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _apagar(
    FeedDeleteEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(FeedLoadingState());
    try {
      await excluirPublicacao(event.id);
      final publicacoes = await listarPublicacoes(forceRefresh: true);
      emit(FeedSuccessState(publicacoes: publicacoes));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(FeedErrorState(errorModel: errorModelFromException(e)));
    }
  }
}
