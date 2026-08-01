import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/function/haptic.dart';
import 'package:app_ramos_candidatura/function/service/api_error.dart';

void showToastSuccess({required String message}) {
  showSnackbarSuccess(message: message);
}

void showToastError({String? message}) {
  vibrateErrorFeedback();
  showSnackbarError(message: message);
}

void showToastWarning({required String message}) {
  showSnackbarWarning(message: message);
}

/// Snackbar longo com indicador de progresso (ex.: download offline).
void showToastProgress({required String message}) {
  final messenger = ScaffoldMessenger.of(AppContext.context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(minutes: 2),
        backgroundColor: RamosColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
}

void hideToastProgress() {
  ScaffoldMessenger.of(AppContext.context).hideCurrentSnackBar();
}

void showAppErrorSnackbar(ErrorModel errorModel) {
  final message = errorModel.mensagem?.trim();
  if (message == null || message.isEmpty) return;
  vibrateErrorFeedback();
  showSnackbarError(message: message);
}

void showAppErrorFromException(Object error) {
  showAppErrorSnackbar(errorModelFromException(error));
}
