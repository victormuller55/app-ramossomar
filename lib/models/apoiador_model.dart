class ApoiadorModel {
  String? id;
  String? idLider;
  String? nomeLider;
  String? nome;
  String? cpf;
  String? dataNascimento;
  String? telefone;
  String? whatsapp;
  String? cep;
  String? endereco;
  String? numero;
  String? complemento;
  String? bairro;
  String? cidade;
  String? localVotacao;
  String? intencaoVoto;
  String? observacoes;
  String? dataCriacao;
  String? dataAtualizacao;

  /// Id local da fila offline — nunca enviado à API.
  String? localId;

  bool get pendenteEnvio => localId != null && localId!.isNotEmpty;

  ApoiadorModel({
    this.id,
    this.idLider,
    this.nomeLider,
    this.nome,
    this.cpf,
    this.dataNascimento,
    this.telefone,
    this.whatsapp,
    this.cep,
    this.endereco,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.localVotacao,
    this.intencaoVoto,
    this.observacoes,
    this.dataCriacao,
    this.dataAtualizacao,
    this.localId,
  });

  factory ApoiadorModel.empty() {
    return ApoiadorModel(
      id: null,
      idLider: null,
      nomeLider: '',
      nome: '',
      cpf: '',
      dataNascimento: null,
      telefone: '',
      whatsapp: '',
      cep: '',
      endereco: '',
      numero: '',
      complemento: '',
      bairro: '',
      cidade: '',
      localVotacao: '',
      intencaoVoto: null,
      observacoes: '',
      dataCriacao: null,
      dataAtualizacao: null,
      localId: null,
    );
  }

  String get contatoPrincipal {
    if (whatsapp != null && whatsapp!.trim().isNotEmpty) return whatsapp!.trim();
    if (telefone != null && telefone!.trim().isNotEmpty) return telefone!.trim();
    return '';
  }

  String get iniciais {
    final parts = (nome ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  ApoiadorModel.fromMap(Map<String, dynamic> json) {
    id = json['id']?.toString();
    idLider = (json['id_lider'] ?? json['idLider'])?.toString();
    nomeLider = (json['nome_lider'] ?? json['nomeLider'])?.toString();
    nome = json['nome']?.toString();
    cpf = json['cpf']?.toString();
    dataNascimento = (json['data_nascimento'] ?? json['dataNascimento'])?.toString();
    telefone = json['telefone']?.toString();
    whatsapp = json['whatsapp']?.toString();
    cep = json['cep']?.toString();
    endereco = json['endereco']?.toString();
    numero = json['numero']?.toString();
    complemento = json['complemento']?.toString();
    bairro = json['bairro']?.toString();
    cidade = json['cidade']?.toString();
    localVotacao = (json['local_votacao'] ?? json['localVotacao'])?.toString();
    intencaoVoto = (json['intencao_voto'] ?? json['intencaoVoto'])?.toString();
    observacoes = json['observacoes']?.toString();
    dataCriacao = (json['data_criacao'] ?? json['dataCriacao'])?.toString();
    dataAtualizacao = (json['data_atualizacao'] ?? json['dataAtualizacao'])?.toString();
    localId = json['localId']?.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_lider': idLider,
      'nome_lider': nomeLider,
      'nome': nome,
      'cpf': cpf,
      'data_nascimento': dataNascimento,
      'telefone': telefone,
      'whatsapp': whatsapp,
      'cep': cep,
      'endereco': endereco,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'local_votacao': localVotacao,
      'intencao_voto': intencaoVoto,
      'observacoes': observacoes,
      'data_criacao': dataCriacao,
      'data_atualizacao': dataAtualizacao,
      if (localId != null) 'localId': localId,
    };
  }

  Map<String, dynamic> toJsonCadastro() {
    final cpfDigits = (cpf ?? '').replaceAll(RegExp(r'\D'), '');
    final telefoneDigits = (telefone ?? '').replaceAll(RegExp(r'\D'), '');
    final whatsappDigits = (whatsapp ?? '').replaceAll(RegExp(r'\D'), '');
    final cepDigits = (cep ?? '').replaceAll(RegExp(r'\D'), '');

    return {
      'id_lider': idLider,
      'nome': nome ?? '',
      'cpf': cpfDigits.isEmpty ? null : cpfDigits,
      'data_nascimento':
          (dataNascimento != null && dataNascimento!.isNotEmpty) ? dataNascimento : null,
      'telefone': telefoneDigits.isEmpty ? null : telefoneDigits,
      'whatsapp': whatsappDigits.isEmpty ? null : whatsappDigits,
      'cep': cepDigits.isEmpty ? null : cepDigits,
      'endereco': (endereco != null && endereco!.trim().isNotEmpty) ? endereco : null,
      'numero': (numero != null && numero!.trim().isNotEmpty) ? numero : null,
      'complemento':
          (complemento != null && complemento!.trim().isNotEmpty) ? complemento : null,
      'bairro': (bairro != null && bairro!.trim().isNotEmpty) ? bairro : null,
      'cidade': cidade ?? '',
      'local_votacao': localVotacao ?? '',
      'intencao_voto': intencaoVoto,
      'observacoes':
          (observacoes != null && observacoes!.trim().isNotEmpty) ? observacoes : null,
    };
  }

  Map<String, dynamic> toJsonAlterar() {
    return {'id': id, ...toJsonCadastro()};
  }
}
