import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_ramos_candidatura/app_config/app_platform.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

/// Switch adaptativo: Cupertino no iOS, Material nos demais.
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? RamosColors.primary;

    if (isIOSPlatform) {
      return CupertinoSwitch(
        value: value,
        activeTrackColor: color,
        onChanged: onChanged,
      );
    }

    return Switch(
      value: value,
      activeThumbColor: color,
      onChanged: onChanged,
    );
  }
}
