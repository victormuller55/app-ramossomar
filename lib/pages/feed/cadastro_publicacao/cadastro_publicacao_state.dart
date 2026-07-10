import 'package:muller_package/muller_package.dart';

abstract class CadastroPublicacaoState {}

class CadastroPublicacaoInitialState extends CadastroPublicacaoState {}

class CadastroPublicacaoLoadingState extends CadastroPublicacaoState {}

class CadastroPublicacaoSuccessState extends CadastroPublicacaoState {}

class CadastroPublicacaoErrorState extends CadastroPublicacaoState {
  final ErrorModel errorModel;

  CadastroPublicacaoErrorState({required this.errorModel});
}
