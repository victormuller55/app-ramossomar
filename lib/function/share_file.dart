import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:app_ramos_candidatura/app_config/app_platform.dart';

String mimeTypeForExtension(String ext) {
  switch (ext.toLowerCase()) {
    case 'pdf':
      return 'application/pdf';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'xls':
      return 'application/vnd.ms-excel';
    default:
      return 'application/octet-stream';
  }
}

Rect shareOriginFromContext(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box != null && box.hasSize) {
    final origin = box.localToGlobal(Offset.zero) & box.size;
    if (origin.width > 0 && origin.height > 0) return origin;
  }

  // iPad exige um rect válido; usa o centro da tela como fallback.
  final size = MediaQuery.sizeOf(context);
  return Rect.fromCenter(
    center: Offset(size.width / 2, size.height / 2),
    width: 2,
    height: 2,
  );
}

/// Compartilha arquivo de forma compatível com iOS (UTI/MIME + sharePositionOrigin).
Future<ShareResult> shareAppFile(
  BuildContext context, {
  required String filePath,
  String? fileName,
  String? subject,
}) async {
  final origin = shareOriginFromContext(context);

  final source = File(filePath);
  if (!await source.exists()) {
    throw StateError('Arquivo não encontrado para compartilhar: $filePath');
  }

  final name = fileName ?? source.uri.pathSegments.last;
  final ext = name.contains('.') ? name.split('.').last : '';
  final mime = mimeTypeForExtension(ext);

  // No iOS, copia para Documents com nome limpo — mais confiável no share sheet.
  var pathToShare = source.path;
  if (isIOSPlatform) {
    final docs = await getApplicationDocumentsDirectory();
    final shareDir = Directory('${docs.path}/shares');
    if (!await shareDir.exists()) {
      await shareDir.create(recursive: true);
    }
    final dest = File('${shareDir.path}/$name');
    await source.copy(dest.path);
    pathToShare = dest.path;
  }

  return Share.shareXFiles(
    [
      XFile(
        pathToShare,
        mimeType: mime,
        name: name,
      ),
    ],
    // Em iOS, `text` + arquivos pode falhar; use só `subject`.
    subject: subject,
    sharePositionOrigin: origin,
    fileNameOverrides: [name],
  );
}
