abstract class LideresEvent {}

class LideresLoadEvent extends LideresEvent {
  final bool forceRefresh;
  final String? nome;
  final bool? ativo;

  LideresLoadEvent({
    this.forceRefresh = false,
    this.nome,
    this.ativo,
  });
}

class LideresLoadMoreEvent extends LideresEvent {}

class LideresDeleteEvent extends LideresEvent {
  final String id;

  LideresDeleteEvent({required this.id});
}
