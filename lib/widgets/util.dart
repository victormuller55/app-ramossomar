import 'package:flutter/material.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

Widget informacao(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 18, color: RamosColors.primary),
      appSizedBox(width: AppSpacing.small),
      Expanded(
        child: appText(text, color: AppColors.grey600),
      ),
    ],
  );
}
