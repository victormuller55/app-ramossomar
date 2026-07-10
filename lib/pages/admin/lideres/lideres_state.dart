import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class LideresState {}

class LideresInitialState extends LideresState {}

class LideresLoadingState extends LideresState {}

class LideresSuccessState extends LideresState {
  final List<UsuarioModel> lideres;

  LideresSuccessState({required this.lideres});
}

class LideresErrorState extends LideresState {
  final ErrorModel errorModel;

  LideresErrorState({required this.errorModel});
}

class LideresDeleteSuccessState extends LideresState {}
