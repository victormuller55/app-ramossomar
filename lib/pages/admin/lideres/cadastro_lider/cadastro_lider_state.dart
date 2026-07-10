import 'package:muller_package/muller_package.dart';

abstract class CadastroLiderState {}

class CadastroLiderInitialState extends CadastroLiderState {}

class CadastroLiderLoadingState extends CadastroLiderState {}

class CadastroLiderSuccessState extends CadastroLiderState {}

class CadastroLiderErrorState extends CadastroLiderState {
  final ErrorModel errorModel;

  CadastroLiderErrorState({required this.errorModel});
}
