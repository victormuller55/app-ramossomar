import 'dart:convert';

import 'package:http/http.dart' as http;

class EnderecoCep {
  final String? logradouro;
  final String? bairro;
  final String? cidade;
  final String? uf;
  final String? complemento;

  const EnderecoCep({
    this.logradouro,
    this.bairro,
    this.cidade,
    this.uf,
    this.complemento,
  });

  factory EnderecoCep.fromMap(Map<String, dynamic> json) {
    return EnderecoCep(
      logradouro: json['logradouro']?.toString(),
      bairro: json['bairro']?.toString(),
      cidade: json['localidade']?.toString(),
      uf: json['uf']?.toString(),
      complemento: json['complemento']?.toString(),
    );
  }
}

Future<EnderecoCep?> buscarEnderecoPorCep(String cep) async {
  final digits = cep.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 8) return null;

  final uri = Uri.parse('https://viacep.com.br/ws/$digits/json/');
  final response = await http.get(uri);
  if (response.statusCode < 200 || response.statusCode >= 300) return null;

  final map = jsonDecode(response.body) as Map<String, dynamic>;
  if (map['erro'] == true || map['erro']?.toString() == 'true') return null;
  return EnderecoCep.fromMap(map);
}
