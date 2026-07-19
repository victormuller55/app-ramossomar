abstract class RelatoriosEvent {}

class RelatoriosExportEvent extends RelatoriosEvent {
  final String formato;
  final String? cidade;
  final String? localVotacao;
  final String? intencaoVoto;

  RelatoriosExportEvent({
    required this.formato,
    this.cidade,
    this.localVotacao,
    this.intencaoVoto,
  });
}
