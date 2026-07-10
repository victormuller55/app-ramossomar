import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

Widget emptyMessage({
  required String title,
  String? subtitle,
  IconData icon = Icons.inbox_outlined,
}) {
  return appContainer(
    radius: BorderRadius.circular(AppRadius.card),
    width: double.infinity,
    backgroundColor: AppColors.white,
    border: Border.all(color: AppColors.grey200),
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.grey600),
          appSizedBox(height: AppSpacing.normal),
          appText(
            title,
            fontSize: AppFontSizes.verySmall,
            bold: true,
            color: AppColors.grey900,
          ),
          if (subtitle != null) ...[
            appSizedBox(height: AppSpacing.small),
            appText(subtitle, color: AppColors.grey600),
          ],
        ],
      ),
    ),
  );
}
