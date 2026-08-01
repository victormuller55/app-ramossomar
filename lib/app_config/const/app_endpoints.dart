/// Base da API de produção.
const String server = 'https://ramossomar.api.convertix.net.br';

/// Emulador Android → máquina host: use `10.0.2.2` (não use 192.168.x nem localhost).
/// Celular físico na mesma rede → use o IP do notebook (ex.: 192.168.0.105).

// const String server = 'http://10.0.2.2:7000';


String get api => '$server/api/v1/ramossomar';

String fotoUrl(String? path) {
  if (path == null || path.trim().isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '$server$path';
}

class AppEndpoints {

  // Auth
  static String endpointAuthLogin = '$api/auth/login';

  // Usuários
  static String endpointUsuarios = '$api/usuarios';
  static String endpointUsuariosNovo = '$api/usuarios/novo';
  static String endpointUsuariosAlterar = '$api/usuarios/alterar-dados';
  static String endpointUsuariosUploadImagem = '$api/usuarios/upload-imagem';
  static String endpointUsuariosApagar = '$api/usuarios/apagar';

  // Apoiadores
  static String endpointApoiadores = '$api/apoiadores';
  static String endpointApoiadoresNovo = '$api/apoiadores/novo';
  static String endpointApoiadoresAlterar = '$api/apoiadores/alterar-dados';
  static String endpointApoiadoresApagar = '$api/apoiadores/apagar';

  // Histórico de apoiadores
  static String endpointHistoricoApoiadores = '$api/historico-apoiadores';
  static String endpointHistoricoApoiadoresNovo = '$api/historico-apoiadores/novo';
  static String endpointHistoricoApoiadoresAlterar = '$api/historico-apoiadores/alterar-dados';
  static String endpointHistoricoApoiadoresApagar = '$api/historico-apoiadores/apagar';

  // Publicações
  static String endpointPublicacoes = '$api/publicacoes';
  static String endpointPublicacoesNovo = '$api/publicacoes/novo';
  static String endpointPublicacoesAlterar = '$api/publicacoes/alterar-dados';
  static String endpointPublicacoesUploadImagens = '$api/publicacoes/upload-imagens';
  static String endpointPublicacoesApagar = '$api/publicacoes/apagar';

  // Relatórios
  static String endpointRelatoriosApoiadores = '$api/relatorios/apoiadores';

  // Cidades
  static String endpointCidades = '$api/cidades';
  static String endpointCidadesTodos = '$api/cidades/todos';
  static String endpointCidadesPorId = '$api/cidades/por-id';
  static String endpointCidadesPorCodigoIbge = '$api/cidades/por-codigo-ibge';

  // Locais de votação
  static String endpointLocaisVotacao = '$api/locais-votacao';
  static String endpointLocaisVotacaoTodos = '$api/locais-votacao/todos';
  static String endpointLocaisVotacaoPorId = '$api/locais-votacao/por-id';
  static String endpointLocaisVotacaoNovo = '$api/locais-votacao/novo';
  static String endpointLocaisVotacaoAlterar = '$api/locais-votacao/alterar-dados';
  static String endpointLocaisVotacaoApagar = '$api/locais-votacao/apagar';

  // Tokens refresh
  static String endpointTokensRefresh = '$api/tokens-refresh';
  static String endpointTokensRefreshNovo = '$api/tokens-refresh/novo';
  static String endpointTokensRefreshAlterar = '$api/tokens-refresh/alterar-dados';
  static String endpointTokensRefreshApagar = '$api/tokens-refresh/apagar';
}
