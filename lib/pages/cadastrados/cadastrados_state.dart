import 'package:app_ramos_candidatura/models/apoiador_model.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class CadastradosState {}

class CadastradosInitialState extends CadastradosState {}

class CadastradosLoadingState extends CadastradosState {}

class CadastradosSuccessState extends CadastradosState {
  final List<ApoiadorModel> apoiadores;
  final UsuarioModel? usuario;
  CadastradosSuccessState({required this.apoiadores, this.usuario});
}

class CadastradosErrorState extends CadastradosState {
  final ErrorModel errorModel;
  CadastradosErrorState({required this.errorModel});
}

class CadastradosDeleteSuccessState extends CadastradosState {}
