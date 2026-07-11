import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Loading adaptativo com cor visível em iOS e Android.
Widget appLoadingRamos({Color? color, double? size}) {
  final indicatorColor = color ?? RamosColors.primary;
  final dimension = size ?? 36.0;
  final isApple = defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  final Widget indicator;
  if (isApple) {
    // CupertinoActivityIndicator precisa de `color` explícito —
    // valueColor do CircularProgressIndicator.adaptive é ignorado no iOS.
    indicator = SizedBox(
      width: dimension,
      height: dimension,
      child: Center(
        child: CupertinoActivityIndicator(
          color: indicatorColor,
          radius: dimension / 2,
        ),
      ),
    );
  } else {
    indicator = SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        strokeWidth: dimension <= 20 ? 2 : 3,
        valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
      ),
    );
  }

  return size == null ? Center(child: indicator) : indicator;
}
