import 'package:muller_package/muller_package.dart';

abstract class RelatoriosState {}

class RelatoriosInitialState extends RelatoriosState {}

class RelatoriosLoadingState extends RelatoriosState {}

class RelatoriosSuccessState extends RelatoriosState {
  final String filePath;
  final String formato;

  RelatoriosSuccessState({required this.filePath, required this.formato});
}

class RelatoriosErrorState extends RelatoriosState {
  final ErrorModel errorModel;

  RelatoriosErrorState({required this.errorModel});
}
