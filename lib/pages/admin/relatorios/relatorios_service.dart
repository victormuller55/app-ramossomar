import 'dart:io';

import 'package:app_ramos_candidatura/app_config/app_platform.dart';
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

  // iOS: Documents é mais confiável para o share sheet do que Temporary.
  final baseDir = isIOSPlatform
      ? await getApplicationDocumentsDirectory()
      : await getTemporaryDirectory();
  final dir = Directory('${baseDir.path}/relatorios');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final stamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-').substring(0, 19);
  final filename = 'cadastrados_$stamp.$formato';
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
