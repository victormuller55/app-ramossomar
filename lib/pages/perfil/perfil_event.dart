import 'package:app_ramos_candidatura/models/usuario_model.dart';

abstract class PerfilEvent {}

class PerfilLoadEvent extends PerfilEvent {}

class PerfilSaveEvent extends PerfilEvent {
  final UsuarioModel usuario;

  PerfilSaveEvent({required this.usuario});
}
