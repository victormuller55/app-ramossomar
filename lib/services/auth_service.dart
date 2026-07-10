import 'package:muller_package/muller_package.dart';
import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';

Future<AppResponse> postAuthLogin({
  required String email,
  required String senha,
}) async {
  return postHTTP(
    endpoint: AppEndpoints.endpointAuthLogin,
    body: {
      'email': email,
      'senha': senha,
    },
  );
}
