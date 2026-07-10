import 'package:flutter/material.dart';
import 'package:app_ramos_candidatura/app_config/const/ramos_colors.dart';

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [RamosColors.primary, RamosColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient loginPanel = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000000),
      Color(0xFF0D2E2A),
      RamosColors.primary,
    ],
    stops: [0, 0.45, 1],
  );
}
