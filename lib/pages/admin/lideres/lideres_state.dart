import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class LideresState {}

class LideresInitialState extends LideresState {}

class LideresLoadingState extends LideresState {}

class LideresSuccessState extends LideresState {
  final List<UsuarioModel> lideres;
  final int numPagina;
  final int maxPaginas;
  final int maxItens;
  final bool loadingMore;
  final String? nomeBusca;
  final bool? filtroAtivo;

  LideresSuccessState({
    required this.lideres,
    this.numPagina = 1,
    this.maxPaginas = 0,
    this.maxItens = 0,
    this.loadingMore = false,
    this.nomeBusca,
    this.filtroAtivo,
  });

  bool get temProximaPagina => numPagina < maxPaginas;

  LideresSuccessState copyWith({
    List<UsuarioModel>? lideres,
    int? numPagina,
    int? maxPaginas,
    int? maxItens,
    bool? loadingMore,
    String? nomeBusca,
    bool? filtroAtivo,
    bool clearFiltroAtivo = false,
  }) {
    return LideresSuccessState(
      lideres: lideres ?? this.lideres,
      numPagina: numPagina ?? this.numPagina,
      maxPaginas: maxPaginas ?? this.maxPaginas,
      maxItens: maxItens ?? this.maxItens,
      loadingMore: loadingMore ?? this.loadingMore,
      nomeBusca: nomeBusca ?? this.nomeBusca,
      filtroAtivo: clearFiltroAtivo ? null : (filtroAtivo ?? this.filtroAtivo),
    );
  }
}

class LideresErrorState extends LideresState {
  final ErrorModel errorModel;

  LideresErrorState({required this.errorModel});
}

class LideresDeleteSuccessState extends LideresState {}
