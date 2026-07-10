import 'dart:io';

import 'package:app_ramos_candidatura/services/relatorio_service.dart';
import 'package:path_provider/path_provider.dart';

Future<String> exportarRelatorioApoiadores({
  required String formato,
  String? cidade,
  String? intencaoVoto,
}) async {
  final bytes = await downloadRelatorioApoiadores(
    formato: formato,
    cidade: cidade,
    intencaoVoto: intencaoVoto,
  );

  final dir = await getTemporaryDirectory();
  final stamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-').substring(0, 19);
  final filename = 'cadastrados_$stamp.$formato';
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
