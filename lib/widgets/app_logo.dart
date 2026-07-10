import 'package:flutter/material.dart';

const String logoAsset = 'assets/images/logo_ramos_somar.png';

Widget appLogoRamos({
  double height = 120,
  Alignment alignment = Alignment.center,
}) {
  final cacheHeight = (height * 2).round();

  return Align(
    alignment: alignment,
    child: Image.asset(
      logoAsset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      cacheHeight: cacheHeight,
    ),
  );
}
