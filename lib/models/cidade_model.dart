class CidadeModel {
  String? id;
  String? codigoIbge;
  String? nome;
  String? uf;
  String? dataCriacao;
  String? dataAtualizacao;

  CidadeModel({
    this.id,
    this.codigoIbge,
    this.nome,
    this.uf,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  factory CidadeModel.fromMap(Map<String, dynamic> json) {
    return CidadeModel(
      id: json['id']?.toString(),
      codigoIbge: (json['codigo_ibge'] ?? json['codigoIbge'])?.toString(),
      nome: json['nome']?.toString(),
      uf: json['uf']?.toString(),
      dataCriacao: (json['data_criacao'] ?? json['dataCriacao'])?.toString(),
      dataAtualizacao:
          (json['data_atualizacao'] ?? json['dataAtualizacao'])?.toString(),
    );
  }

  String get label {
    final n = nome ?? '';
    final u = uf ?? '';
    if (n.isEmpty) return '';
    if (u.isEmpty) return n;
    return '$n/$u';
  }
}
