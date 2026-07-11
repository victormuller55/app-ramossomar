import 'package:flutter/material.dart';

const String logoAsset = 'assets/images/logo_ramos_somar.png';

Widget appLogoRamos({
  Alignment alignment = Alignment.center,
  double? height,
  double? width,
}) {
  return Align(
    alignment: alignment,
    child: Image.asset(
      logoAsset,
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    ),
  );
}
