import 'package:muller_package/app_consts/app_strings.dart';
import 'package:muller_package/functions/validators.dart';

export 'package:muller_package/functions/formatters.dart'
    show formataCPF, formataCelular;
export 'package:muller_package/functions/validators.dart' show validaCPF;

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'E-mail é obrigatório';
  if (!validaEmail(value)) return AppStrings.emailInvalido;
  return null;
}

String? validateSenhaLogin(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Digite sua senha';
  }
  return null;
}

String? validateSenhaCadastro(String? value) {
  if (value == null || value.trim().isEmpty) return 'Senha é obrigatória';
  if (value.trim().length < 6) return 'Senha deve ter no mínimo 6 caracteres';
  return null;
}

String? validateSenhaOpcional(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  if (value.trim().length < 6) return 'Senha deve ter no mínimo 6 caracteres';
  return null;
}

String? validateCpf(String? value) {
  if (value == null || value.trim().isEmpty) return 'CPF é obrigatório';
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 11 || !validaCPF(digits)) return 'CPF inválido';
  return null;
}

String? validateNome(String? value) {
  if (value == null || value.trim().isEmpty) return 'Nome é obrigatório';
  if (value.trim().length < 3) return 'Informe o nome completo';
  return null;
}

String? validateTituloPublicacao(String? value) {
  if (value == null || value.trim().isEmpty) return 'Título é obrigatório';
  if (value.trim().length < 3) return 'Informe um título válido';
  return null;
}

String? validateConteudoPublicacao(String? value) {
  if (value == null || value.trim().isEmpty) return 'Conteúdo é obrigatório';
  if (value.trim().length < 5) return 'Informe um conteúdo válido';
  return null;
}

String? validateDataNascimento(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 8) return 'Data inválida';
  final day = int.tryParse(digits.substring(0, 2));
  final month = int.tryParse(digits.substring(2, 4));
  final year = int.tryParse(digits.substring(4, 8));
  if (day == null || month == null || year == null) return 'Data inválida';
  try {
    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month || date.year != year) {
      return 'Data inválida';
    }
    if (date.isAfter(DateTime.now())) return 'Data não pode ser futura';
  } catch (_) {
    return 'Data inválida';
  }
  return null;
}
