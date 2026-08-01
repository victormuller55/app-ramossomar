import 'package:app_ramos_candidatura/models/publicacao_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class FeedState {}

class FeedInitialState extends FeedState {}

class FeedLoadingState extends FeedState {}

class FeedSuccessState extends FeedState {
  final List<PublicacaoModel> publicacoes;
  final int numPagina;
  final int maxPaginas;
  final int maxItens;
  final bool loadingMore;
  final bool offline;

  FeedSuccessState({
    required this.publicacoes,
    this.numPagina = 1,
    this.maxPaginas = 0,
    this.maxItens = 0,
    this.loadingMore = false,
    this.offline = false,
  });

  bool get temProximaPagina => !offline && numPagina < maxPaginas;

  FeedSuccessState copyWith({
    List<PublicacaoModel>? publicacoes,
    int? numPagina,
    int? maxPaginas,
    int? maxItens,
    bool? loadingMore,
    bool? offline,
  }) {
    return FeedSuccessState(
      publicacoes: publicacoes ?? this.publicacoes,
      numPagina: numPagina ?? this.numPagina,
      maxPaginas: maxPaginas ?? this.maxPaginas,
      maxItens: maxItens ?? this.maxItens,
      loadingMore: loadingMore ?? this.loadingMore,
      offline: offline ?? this.offline,
    );
  }
}

class FeedErrorState extends FeedState {
  final ErrorModel errorModel;

  FeedErrorState({required this.errorModel});
}
