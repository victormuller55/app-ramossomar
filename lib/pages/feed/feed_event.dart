abstract class FeedEvent {}

class FeedLoadEvent extends FeedEvent {
  final bool forceRefresh;
  FeedLoadEvent({this.forceRefresh = false});
}
