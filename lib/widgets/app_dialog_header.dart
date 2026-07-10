import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

Widget appDialogHeader({
  required String title,
  required IconData icon,
  String? subtitle,
  VoidCallback? onClose,
}) {
  return appContainer(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    backgroundColor: AppColors.black.withValues(alpha: 0.9),
    radius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
    border: Border(
      bottom: BorderSide(color: RamosColors.primary.withValues(alpha: 0.15)),
    ),
    child: Row(
      children: [
        _dialogHeaderIcon(icon),
        appSizedBox(width: AppSpacing.small),
        Expanded(child: _dialogHeaderTitles(title.toUpperCase(), subtitle)),
        if (onClose != null) _dialogHeaderCloseButton(onClose),
      ],
    ),
  );
}

Widget _dialogHeaderIcon(IconData icon) {
  return appContainer(
    width: 32,
    height: 32,
    backgroundColor: AppColors.grey900,
    radius: BorderRadius.circular(6),
    border: Border.all(color: RamosColors.primary.withValues(alpha: 0.22)),
    child: Center(child: Icon(icon, color: AppColors.white, size: 18)),
  );
}

Widget _dialogHeaderTitles(String title, String? subtitle) {
  if (subtitle == null) {
    return _dialogHeaderTitleText(title);
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [_dialogHeaderTitleText(title), _dialogHeaderSubtitleText(subtitle)],
  );
}

Widget _dialogHeaderTitleText(String title) {
  return appText(
    title,
    color: AppColors.white,
    bold: true,
    fontSize: AppFontSizes.verySmall,
  );
}

Widget _dialogHeaderSubtitleText(String subtitle) {
  return appText(subtitle, color: AppColors.white, fontSize: AppFontSizes.verySmall);
}

Widget _dialogHeaderCloseButton(VoidCallback onClose) {
  return IconButton(
    onPressed: onClose,
    icon: const Icon(Icons.close, color: Colors.white, size: 18),
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
    visualDensity: VisualDensity.compact,
  );
}
