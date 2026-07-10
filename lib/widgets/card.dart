import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

Widget card({required Widget child, EdgeInsetsGeometry? padding}) {
  return appContainer(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(20),
    backgroundColor: AppColors.white,
    radius: BorderRadius.circular(AppRadius.card),
    border: Border.all(color: AppColors.grey200),
    child: child,
  );
}

Widget appCardWrap({required Widget child}) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 720),
    child: child,
  );
}
