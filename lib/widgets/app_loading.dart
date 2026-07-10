import 'package:flutter/material.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

/// Loading adaptativo: no iOS usa o indicador nativo atual do sistema.
Widget appLoadingRamos({
  Color? color,
  double? size,
}) {
  final indicatorColor = color ?? RamosColors.primary;
  final dimension = size ?? 36.0;

  final indicator = SizedBox(
    width: dimension,
    height: dimension,
    child: CircularProgressIndicator.adaptive(
      valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
      strokeWidth: size != null ? 2 : 3,
    ),
  );

  return size == null ? Center(child: indicator) : indicator;
}
