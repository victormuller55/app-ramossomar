import 'package:flutter/material.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

Widget ramosAddFab({
  required VoidCallback onTap,
  Object? heroTag,
}) {
  return FloatingActionButton(
    onPressed: onTap,
    heroTag: heroTag,
    backgroundColor: RamosColors.secondary,
    foregroundColor: RamosColors.primaryDark,
    elevation: 4,
    child: const Icon(Icons.add_rounded, size: 30),
  );
}
