import 'dart:typed_data';

import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';
import 'package:app_ramos_candidatura/function/service/http_helper.dart';

Future<Uint8List> downloadRelatorioApoiadores({
  required String formato,
  String? cidade,
  String? intencaoVoto,
  String? idLider,
}) async {
  final params = <String, String>{
    'formato': formato,
  };
  if (cidade != null && cidade.isNotEmpty) params['cidade'] = cidade;
  if (intencaoVoto != null && intencaoVoto.isNotEmpty) {
    params['intencao_voto'] = intencaoVoto;
  }
  if (idLider != null && idLider.isNotEmpty) params['id_lider'] = idLider;

  return getBytes(
    endpoint: AppEndpoints.endpointRelatoriosApoiadores,
    parameters: params,
  );
}
