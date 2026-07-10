import 'package:muller_package/muller_package.dart';

class ErrorResponseModel {
  DateTime? timestamp;
  int? status;
  String? error;
  String? message;
  Map<String, String>? errors;

  ErrorResponseModel({this.timestamp, this.status, this.error, this.message, this.errors});

  ErrorResponseModel.fromMap(Map<String, dynamic> json) {
    timestamp = json['timestamp'] != null ? DateTime.tryParse(json['timestamp'].toString()) : null;
    status = json['status_code'] ?? json['status'];
    error = (json['erro'] ?? json['error'])?.toString();
    message = (json['mensagem'] ?? json['message'])?.toString();
    final rawErrors = json['errors'];
    if (rawErrors is Map) {
      errors = rawErrors.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
  }

  ErrorModel toErrorModel() {
    var mensagem = message ?? error ?? 'Erro desconhecido';
    if (errors != null && errors!.isNotEmpty) {
      mensagem = errors!.values.join('\n');
    }
    return ErrorModel(mensagem: mensagem, erro: error ?? '', tipo: status?.toString() ?? '');
  }
}
