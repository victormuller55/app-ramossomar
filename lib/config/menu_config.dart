import 'package:flutter/material.dart';
import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_page.dart';

class MenuItem {
  final String id;
  final String title;
  final IconData icon;
  final Widget page;
  final List<String> tiposPermitidos;

  const MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.page,
    this.tiposPermitidos = const [],
  });

  bool temPermissao(String? tipo) {
    if (tipo == null || tipo.isEmpty) return false;
    if (tiposPermitidos.isEmpty) return true;
    return tiposPermitidos.contains(tipo);
  }
}

class MenuConfig {
  static List<MenuItem> todosOsItens = [
    MenuItem(
      id: 'inicio',
      title: 'Início',
      icon: Icons.home_outlined,
      page: const CadastradosPage(),
    ),
    MenuItem(
      id: 'admin',
      title: 'Administração',
      icon: Icons.admin_panel_settings_outlined,
      page: Container(),
      tiposPermitidos: [TipoUsuario.admin],
    ),
  ];

  static List<MenuItem> getItensParaUsuario(String? tipo) {
    return todosOsItens.where((item) => item.temPermissao(tipo)).toList();
  }

  static MenuItem? getItemPorId(String id) {
    try {
      return todosOsItens.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
