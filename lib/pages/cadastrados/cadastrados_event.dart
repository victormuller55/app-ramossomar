abstract class CadastradosEvent {}

class CadastradosLoadEvent extends CadastradosEvent {
  final bool forceRefresh;
  CadastradosLoadEvent({this.forceRefresh = false});
}

class CadastradosDeleteEvent extends CadastradosEvent {
  final String id;
  CadastradosDeleteEvent({required this.id});
}
