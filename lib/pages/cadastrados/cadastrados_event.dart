abstract class CadastradosEvent {}

class CadastradosLoadEvent extends CadastradosEvent {
  final bool forceRefresh;
  final String? nome;

  CadastradosLoadEvent({this.forceRefresh = false, this.nome});
}

class CadastradosLoadMoreEvent extends CadastradosEvent {}

class CadastradosDeleteEvent extends CadastradosEvent {
  final String? id;
  final String? localId;

  CadastradosDeleteEvent({this.id, this.localId});
}
