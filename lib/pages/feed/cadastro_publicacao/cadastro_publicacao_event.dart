import 'package:app_ramos_candidatura/models/publicacao_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class CadastroPublicacaoEvent {}

class CadastroPublicacaoSaveEvent extends CadastroPublicacaoEvent {
  final PublicacaoModel publicacao;
  final List<XFile> imagens;
  final bool isEdit;

  CadastroPublicacaoSaveEvent({
    required this.publicacao,
    this.imagens = const [],
    this.isEdit = false,
  });
}
