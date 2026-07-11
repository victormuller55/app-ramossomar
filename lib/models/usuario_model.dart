class UsuarioModel {
  String? id;
  String? nome;
  String? email;
  String? tipo;
  bool? ativo;
  String? telefone;
  String? senha;
  String? token;
  String? refreshToken;
  String? foto;
  String? expiraEm;

  UsuarioModel({
    this.id,
    this.nome,
    this.email,
    this.tipo,
    this.ativo,
    this.telefone,
    this.senha,
    this.token,
    this.refreshToken,
    this.foto,
    this.expiraEm,
  });

  factory UsuarioModel.empty() {
    return UsuarioModel(
      id: null,
      nome: '',
      email: '',
      tipo: null,
      ativo: null,
      telefone: null,
      senha: null,
      token: null,
      refreshToken: null,
      foto: null,
      expiraEm: null,
    );
  }

  bool get isAdmin => tipo == 'ADMIN';

  bool get isLider => tipo == 'LIDER';

  UsuarioModel.fromMap(Map<String, dynamic> json) {
    id = (json['id_usuario'] ?? json['id'])?.toString();
    nome = json['nome']?.toString();
    email = json['email']?.toString();
    tipo = (json['perfil'] ?? json['tipo'])?.toString();
    ativo = json['ativo'] is bool ? json['ativo'] as bool : null;
    telefone = json['telefone']?.toString();
    senha = json['senha']?.toString();
    token = (json['access_token'] ?? json['token'])?.toString();
    refreshToken = json['refresh_token']?.toString();
    foto = (json['imagem'] ?? json['foto'])?.toString();
    expiraEm = json['expira_em']?.toString();
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'nome': nome ?? '',
      'email': email ?? '',
      'senha': senha ?? '',
      'perfil': tipo ?? 'LIDER',
      if (telefone != null && telefone!.isNotEmpty) 'telefone': telefone,
      'ativo': ativo ?? true,
    };
  }

  Map<String, dynamic> toJsonAlterar() {
    return {
      'id': id,
      'nome': nome ?? '',
      'email': email ?? '',
      if (senha != null && senha!.isNotEmpty) 'senha': senha,
      'perfil': tipo,
      if (telefone != null) 'telefone': telefone,
      'ativo': ativo ?? true,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'perfil': tipo,
      'ativo': ativo,
      'telefone': telefone,
      'imagem': foto,
      'token': token,
      'refresh_token': refreshToken,
      'expira_em': expiraEm,
    };
  }
}
