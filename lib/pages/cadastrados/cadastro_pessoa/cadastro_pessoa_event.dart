import 'package:app_ramos_candidatura/models/apoiador_model.dart';

abstract class CadastroPessoaEvent {}

class CadastroPessoaSaveEvent extends CadastroPessoaEvent {
  final ApoiadorModel apoiador;
  CadastroPessoaSaveEvent({required this.apoiador});
}
