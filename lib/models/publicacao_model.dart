class PublicacaoModel {
  String? id;
  String? idAutor;
  String? nomeAutor;
  String? titulo;
  String? conteudo;
  List<String> imagens;
  String? dataCriacao;
  String? dataAtualizacao;

  PublicacaoModel({
    this.id,
    this.idAutor,
    this.nomeAutor,
    this.titulo,
    this.conteudo,
    List<String>? imagens,
    this.dataCriacao,
    this.dataAtualizacao,
  }) : imagens = imagens ?? <String>[];

  factory PublicacaoModel.empty() {
    return PublicacaoModel(
      id: null,
      idAutor: null,
      nomeAutor: '',
      titulo: '',
      conteudo: '',
      imagens: <String>[],
      dataCriacao: null,
      dataAtualizacao: null,
    );
  }

  bool get temImagens => imagens.isNotEmpty;

  String get iniciaisAutor {
    final parts = (nomeAutor ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static List<String> _parseImagens(dynamic value) {
    if (value is! List) return <String>[];
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  PublicacaoModel.fromMap(Map<String, dynamic> json)
      : imagens = _parseImagens(json['imagens']) {
    id = json['id']?.toString();
    idAutor = (json['id_autor'] ?? json['idAutor'])?.toString();
    nomeAutor = (json['nome_autor'] ?? json['nomeAutor'])?.toString();
    titulo = json['titulo']?.toString();
    conteudo = json['conteudo']?.toString();
    dataCriacao = (json['data_criacao'] ?? json['dataCriacao'])?.toString();
    dataAtualizacao =
        (json['data_atualizacao'] ?? json['dataAtualizacao'])?.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_autor': idAutor,
      'nome_autor': nomeAutor,
      'titulo': titulo,
      'conteudo': conteudo,
      'imagens': imagens,
      'data_criacao': dataCriacao,
      'data_atualizacao': dataAtualizacao,
    };
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'id_autor': idAutor,
      'titulo': titulo ?? '',
      'conteudo': conteudo ?? '',
    };
  }

  Map<String, dynamic> toJsonAlterar() {
    return {
      'id': id,
      'id_autor': idAutor,
      'titulo': titulo ?? '',
      'conteudo': conteudo ?? '',
    };
  }
}
