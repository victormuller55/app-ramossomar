import 'package:app_ramos_candidatura/models/publicacao_model.dart';

abstract class CadastroPublicacaoEvent {}

class CadastroPublicacaoSaveEvent extends CadastroPublicacaoEvent {
  final PublicacaoModel publicacao;
  CadastroPublicacaoSaveEvent({required this.publicacao});
}
