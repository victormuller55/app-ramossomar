import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

Widget ramosAddFab({
  required VoidCallback onTap,
  Object? heroTag,
}) {
  return FloatingActionButton.extended(
    onPressed: onTap,
    heroTag: heroTag,
    backgroundColor: RamosColors.secondary,
    foregroundColor: RamosColors.primaryDark,
    elevation: 4,
    icon: const Icon(Icons.add_rounded, size: 26),
    label: appText(
      'NOVO',
      fontSize: AppFontSizes.small,
      bold: true,
      color: RamosColors.primaryDark,
    ),
  );
}
