import 'package:connectivity_plus/connectivity_plus.dart';

/// Retorna true se houver qualquer interface de rede ativa (não `none`).
Future<bool> temConexao() async {
  final results = await Connectivity().checkConnectivity();
  if (results.isEmpty) return false;
  return results.any((r) => r != ConnectivityResult.none);
}

Stream<List<ConnectivityResult>> onConnectivityChanged() {
  return Connectivity().onConnectivityChanged;
}

bool connectivityResultsOnline(List<ConnectivityResult> results) {
  if (results.isEmpty) return false;
  return results.any((r) => r != ConnectivityResult.none);
}
