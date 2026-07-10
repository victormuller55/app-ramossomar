import 'package:muller_package/muller_package.dart';

abstract class CadastroPessoaState {}

class CadastroPessoaInitialState extends CadastroPessoaState {}

class CadastroPessoaLoadingState extends CadastroPessoaState {}

class CadastroPessoaSuccessState extends CadastroPessoaState {}

class CadastroPessoaErrorState extends CadastroPessoaState {
  final ErrorModel errorModel;
  CadastroPessoaErrorState({required this.errorModel});
}
