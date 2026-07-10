import 'package:app_ramos_candidatura/models/usuario_model.dart';

abstract class CadastroLiderEvent {}

class CadastroLiderSaveEvent extends CadastroLiderEvent {
  final UsuarioModel lider;
  CadastroLiderSaveEvent({required this.lider});
}
