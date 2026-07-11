abstract class FeedEvent {}

class FeedLoadEvent extends FeedEvent {
  final bool forceRefresh;
  FeedLoadEvent({this.forceRefresh = false});
}

class FeedDeleteEvent extends FeedEvent {
  final String id;
  FeedDeleteEvent({required this.id});
}
