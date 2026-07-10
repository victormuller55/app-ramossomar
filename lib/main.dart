import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:app_ramos_candidatura/app_config/app_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      details.exceptionAsString(),
      name: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log(
      error.toString(),
      name: 'PlatformError',
      error: error,
      stackTrace: stack,
    );
    // true = erro tratado (evita kill silencioso; logs ficam visíveis no flutter run)
    return true;
  };

  runApp(const AppWidget());
}
