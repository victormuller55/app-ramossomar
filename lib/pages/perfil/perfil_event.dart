import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class PerfilEvent {}

class PerfilLoadEvent extends PerfilEvent {}

class PerfilSaveEvent extends PerfilEvent {
  final UsuarioModel usuario;

  PerfilSaveEvent({required this.usuario});
}

class PerfilUploadImagemEvent extends PerfilEvent {
  final XFile imagem;

  PerfilUploadImagemEvent({required this.imagem});
}
