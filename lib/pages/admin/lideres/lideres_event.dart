abstract class LideresEvent {}

class LideresLoadEvent extends LideresEvent {
  final bool forceRefresh;

  LideresLoadEvent({this.forceRefresh = false});
}

class LideresDeleteEvent extends LideresEvent {
  final String id;

  LideresDeleteEvent({required this.id});
}
