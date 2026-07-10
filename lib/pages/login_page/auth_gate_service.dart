import 'package:app_ramos_candidatura/app_config/app_auth.dart';

Future<bool> verificarSessaoAuthGate() async {
  return hasSessaoValida();
}
