class LocalVotacaoModel {
  String? id;
  String? codigoTse;
  String? nome;
  String? endereco;
  String? bairro;
  String? cep;
  String? zonaEleitoral;
  double? latitude;
  double? longitude;
  bool? ativo;
  String? idCidade;
  String? nomeCidade;
  String? codigoIbge;
  String? uf;
  String? dataCriacao;
  String? dataAtualizacao;

  LocalVotacaoModel({
    this.id,
    this.codigoTse,
    this.nome,
    this.endereco,
    this.bairro,
    this.cep,
    this.zonaEleitoral,
    this.latitude,
    this.longitude,
    this.ativo,
    this.idCidade,
    this.nomeCidade,
    this.codigoIbge,
    this.uf,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  factory LocalVotacaoModel.fromMap(Map<String, dynamic> json) {
    return LocalVotacaoModel(
      id: json['id']?.toString(),
      codigoTse: (json['codigo_tse'] ?? json['codigoTse'])?.toString(),
      nome: json['nome']?.toString(),
      endereco: json['endereco']?.toString(),
      bairro: json['bairro']?.toString(),
      cep: json['cep']?.toString(),
      zonaEleitoral:
          (json['zona_eleitoral'] ?? json['zonaEleitoral'])?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      ativo: json['ativo'] as bool?,
      idCidade: (json['id_cidade'] ?? json['idCidade'])?.toString(),
      nomeCidade: (json['nome_cidade'] ?? json['nomeCidade'])?.toString(),
      codigoIbge: (json['codigo_ibge'] ?? json['codigoIbge'])?.toString(),
      uf: json['uf']?.toString(),
      dataCriacao: (json['data_criacao'] ?? json['dataCriacao'])?.toString(),
      dataAtualizacao:
          (json['data_atualizacao'] ?? json['dataAtualizacao'])?.toString(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String get label {
    final n = nome ?? '';
    final z = zonaEleitoral;
    if (n.isEmpty) return '';
    if (z == null || z.isEmpty) return n;
    return '$n · Zona $z';
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'codigo_tse': codigoTse ?? '',
      'nome': nome ?? '',
      'endereco': endereco ?? '',
      if (bairro != null && bairro!.isNotEmpty) 'bairro': bairro,
      if (cep != null && cep!.isNotEmpty) 'cep': cep,
      'zona_eleitoral': zonaEleitoral ?? '',
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'ativo': ativo ?? true,
      'id_cidade': idCidade,
    };
  }

  Map<String, dynamic> toJsonAlterar() {
    return {
      'id': id,
      ...toJsonCadastro(),
      'ativo': ativo ?? true,
    };
  }
}
