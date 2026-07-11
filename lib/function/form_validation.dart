import 'package:flutter/material.dart';
import 'package:app_ramos_candidatura/function/haptic.dart';

/// Valida o formulário e vibra se houver campo obrigatório inválido.
bool validarFormularioComFeedback(GlobalKey<FormState> formKey) {
  final valido = formKey.currentState?.validate() ?? false;
  if (!valido) {
    vibrateErrorFeedback();
  }
  return valido;
}
