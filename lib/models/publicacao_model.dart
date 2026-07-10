import 'package:app_ramos_candidatura/app_config/app_enums.dart';

class PublicacaoModel {
  String? id;
  String? idAutor;
  String? nomeAutor;
  String? titulo;
  String? conteudo;
  String? midia;
  String? tipoMidia;
  String? dataCriacao;
  String? dataAtualizacao;

  PublicacaoModel({
    this.id,
    this.idAutor,
    this.nomeAutor,
    this.titulo,
    this.conteudo,
    this.midia,
    this.tipoMidia,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  factory PublicacaoModel.empty() {
    return PublicacaoModel(
      id: null,
      idAutor: null,
      nomeAutor: '',
      titulo: '',
      conteudo: '',
      midia: null,
      tipoMidia: null,
      dataCriacao: null,
      dataAtualizacao: null,
    );
  }

  bool get isImagem => tipoMidia == TipoMidia.imagem;

  bool get isVideo => tipoMidia == TipoMidia.video;

  bool get temMidia => midia != null && midia!.trim().isNotEmpty;

  String get iniciaisAutor {
    final parts = (nomeAutor ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  PublicacaoModel.fromMap(Map<String, dynamic> json) {
    id = json['id']?.toString();
    idAutor = (json['id_autor'] ?? json['idAutor'])?.toString();
    nomeAutor = (json['nome_autor'] ?? json['nomeAutor'])?.toString();
    titulo = json['titulo']?.toString();
    conteudo = json['conteudo']?.toString();
    midia = json['midia']?.toString();
    tipoMidia = (json['tipo_midia'] ?? json['tipoMidia'])?.toString();
    dataCriacao = (json['data_criacao'] ?? json['dataCriacao'])?.toString();
    dataAtualizacao = (json['data_atualizacao'] ?? json['dataAtualizacao'])?.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_autor': idAutor,
      'nome_autor': nomeAutor,
      'titulo': titulo,
      'conteudo': conteudo,
      'midia': midia,
      'tipo_midia': tipoMidia,
      'data_criacao': dataCriacao,
      'data_atualizacao': dataAtualizacao,
    };
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'id_autor': idAutor,
      'titulo': titulo ?? '',
      'conteudo': conteudo ?? '',
      if (midia != null && midia!.trim().isNotEmpty) 'midia': midia!.trim(),
      if (tipoMidia != null && tipoMidia!.trim().isNotEmpty) 'tipo_midia': tipoMidia,
    };
  }
}
