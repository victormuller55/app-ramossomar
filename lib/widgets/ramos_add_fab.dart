import 'package:flutter/material.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

Widget ramosAddFab({required VoidCallback onTap}) {
  return FloatingActionButton(
    onPressed: onTap,
    backgroundColor: RamosColors.secondary,
    foregroundColor: RamosColors.primaryDark,
    elevation: 4,
    child: const Icon(Icons.add_rounded, size: 30),
  );
}
