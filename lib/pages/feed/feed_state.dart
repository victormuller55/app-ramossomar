import 'package:muller_package/muller_package.dart';
import 'package:app_ramos_candidatura/models/publicacao_model.dart';

abstract class FeedState {}

class FeedInitialState extends FeedState {}

class FeedLoadingState extends FeedState {}

class FeedSuccessState extends FeedState {
  final List<PublicacaoModel> publicacoes;

  FeedSuccessState({required this.publicacoes});
}

class FeedErrorState extends FeedState {
  final ErrorModel errorModel;

  FeedErrorState({required this.errorModel});
}
