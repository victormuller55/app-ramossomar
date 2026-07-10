import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/app_platform.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/widgets/app_dialog_header.dart';
import 'package:app_ramos_candidatura/widgets/app_elevated_button.dart';

Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Icons.help_outline,
  String confirmLabel = 'Confirmar',
  String cancelLabel = AppStrings.cancelar,
  bool destructive = false,
}) {
  if (isIOSPlatform) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: destructive,
            isDefaultAction: !destructive,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  return showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: AppConfirmDialog(
        title: title,
        message: message,
        icon: icon,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    ),
  );
}

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.confirmLabel,
    required this.cancelLabel,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            appDialogHeader(
              title: title,
              icon: icon,
              onClose: () => Navigator.pop(context, false),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: appText(
                message,
                color: AppColors.grey900,
                fontSize: AppFontSizes.verySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _actionButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = (constraints.maxWidth - AppSpacing.normal) / 2;
        return Row(
          children: [
            Expanded(
              child: appElevatedButtonRamos(
                title: cancelLabel,
                height: 42,
                width: buttonWidth,
                primary: false,
                onTap: () => Navigator.pop(context, false),
              ),
            ),
            appSizedBox(width: AppSpacing.normal),
            Expanded(
              child: destructive
                  ? _destructiveButton(context, buttonWidth)
                  : appElevatedButtonRamos(
                      title: confirmLabel,
                      height: 42,
                      width: buttonWidth,
                      onTap: () => Navigator.pop(context, true),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _destructiveButton(BuildContext context, double buttonWidth) {
    return appElevatedButtonText(
      confirmLabel.toUpperCase(),
      function: () => Navigator.pop(context, true),
      fontSize: AppFontSizes.verySmall,
      height: 42,
      width: buttonWidth,
      color: AppColors.red,
      textColor: AppColors.white,
      borderColor: AppColors.red,
      borderRadius: AppRadius.input,
      borderWidth: 0,
    );
  }
}
