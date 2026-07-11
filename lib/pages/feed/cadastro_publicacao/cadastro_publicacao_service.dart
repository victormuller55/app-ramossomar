import 'dart:convert';

import 'package:app_ramos_candidatura/cache/cache_keys.dart';
import 'package:app_ramos_candidatura/cache/page_data_cache.dart';
import 'package:app_ramos_candidatura/models/publicacao_model.dart';
import 'package:app_ramos_candidatura/services/publicacao_service.dart';
import 'package:image_picker/image_picker.dart';

Future<PublicacaoModel> criarPublicacao(
  PublicacaoModel publicacao, {
  List<XFile> imagens = const [],
}) async {
  final response = await postPublicacao(publicacao.toJsonCadastro());
  var criada = response.body.isEmpty
      ? publicacao
      : PublicacaoModel.fromMap(
          Map<String, dynamic>.from(jsonDecode(response.body) as Map),
        );

  final id = criada.id;
  if (imagens.isNotEmpty && id != null && id.isNotEmpty) {
    final upload = await uploadImagensPublicacao(id: id, imagens: imagens);
    if (upload.body.isNotEmpty) {
      criada = PublicacaoModel.fromMap(
        Map<String, dynamic>.from(jsonDecode(upload.body) as Map),
      );
    }
  }

  await PageDataCache.invalidate(CacheKeys.publicacoes);
  return criada;
}
