import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

Widget emptyMessage({
  required String title,
  String? subtitle,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        appText(
          title,
          fontSize: AppFontSizes.verySmall,
          bold: true,
          color: AppColors.grey900,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          appSizedBox(height: AppSpacing.small),
          appText(
            subtitle,
            color: AppColors.grey600,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    ),
  );
}
