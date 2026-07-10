import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class PerfilState {}

class PerfilInitialState extends PerfilState {}

class PerfilLoadingState extends PerfilState {}

class PerfilLoadedState extends PerfilState {
  final UsuarioModel usuario;

  PerfilLoadedState({required this.usuario});
}

class PerfilSuccessState extends PerfilState {
  final UsuarioModel usuario;

  PerfilSuccessState({required this.usuario});
}

class PerfilErrorState extends PerfilState {
  final ErrorModel errorModel;

  PerfilErrorState({required this.errorModel});
}
