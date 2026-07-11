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
      RamosColors.primaryDark,
      RamosColors.primary,
      Color(0xFF1A6B63),
    ],
    stops: [0, 0.55, 1],
  );
}