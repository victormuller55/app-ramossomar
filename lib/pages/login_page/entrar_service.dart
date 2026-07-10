import 'dart:convert';

import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/services/auth_service.dart';

Future<UsuarioModel> loginWeb({
  required String email,
  required String senha,
}) async {
  final response = await postAuthLogin(email: email, senha: senha);
  final map = jsonDecode(response.body) as Map<String, dynamic>;
  return UsuarioModel.fromMap(map);
}
