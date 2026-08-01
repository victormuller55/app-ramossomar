import 'package:app_ramos_candidatura/models/apoiador_model.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class CadastradosState {}

class CadastradosInitialState extends CadastradosState {}

class CadastradosLoadingState extends CadastradosState {}

class CadastradosSuccessState extends CadastradosState {
  final List<ApoiadorModel> apoiadores;
  final UsuarioModel? usuario;
  final bool offline;
  final int numPagina;
  final int maxPaginas;
  final int maxItens;
  final bool loadingMore;
  final String? nomeBusca;

  CadastradosSuccessState({
    required this.apoiadores,
    this.usuario,
    this.offline = false,
    this.numPagina = 1,
    this.maxPaginas = 0,
    this.maxItens = 0,
    this.loadingMore = false,
    this.nomeBusca,
  });

  bool get temProximaPagina => !offline && numPagina < maxPaginas;

  CadastradosSuccessState copyWith({
    List<ApoiadorModel>? apoiadores,
    UsuarioModel? usuario,
    bool? offline,
    int? numPagina,
    int? maxPaginas,
    int? maxItens,
    bool? loadingMore,
    String? nomeBusca,
  }) {
    return CadastradosSuccessState(
      apoiadores: apoiadores ?? this.apoiadores,
      usuario: usuario ?? this.usuario,
      offline: offline ?? this.offline,
      numPagina: numPagina ?? this.numPagina,
      maxPaginas: maxPaginas ?? this.maxPaginas,
      maxItens: maxItens ?? this.maxItens,
      loadingMore: loadingMore ?? this.loadingMore,
      nomeBusca: nomeBusca ?? this.nomeBusca,
    );
  }
}

class CadastradosErrorState extends CadastradosState {
  final ErrorModel errorModel;
  CadastradosErrorState({required this.errorModel});
}

class CadastradosDeleteSuccessState extends CadastradosState {}
