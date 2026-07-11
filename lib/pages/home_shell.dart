import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/app_config/app_theme.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_page.dart';
import 'package:app_ramos_candidatura/pages/feed/feed_page.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/lideres_page.dart';
import 'package:app_ramos_candidatura/pages/perfil/perfil_page.dart';
import 'package:app_ramos_candidatura/pages/admin/relatorios/relatorios_page.dart';
import 'package:app_ramos_candidatura/widgets/app_loading.dart';

class _HomeNavItem {
  final String id;
  final IconData iconOutlined;
  final IconData iconSelected;
  final Widget page;

  const _HomeNavItem({
    required this.id,
    required this.iconOutlined,
    required this.iconSelected,
    required this.page,
  });
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  bool _carregando = true;
  bool _isAdmin = false;
  int _currentIndex = 0;

  List<_HomeNavItem> get _items {
    if (_isAdmin) {
      return const [
        _HomeNavItem(
          id: 'cadastrados',
          iconOutlined: Icons.groups_outlined,
          iconSelected: Icons.groups_rounded,
          page: CadastradosPage(),
        ),
        _HomeNavItem(
          id: 'feed',
          iconOutlined: Icons.article_outlined,
          iconSelected: Icons.article_rounded,
          page: FeedPage(showAddFab: true),
        ),
        _HomeNavItem(
          id: 'perfil',
          iconOutlined: Icons.person_outline_rounded,
          iconSelected: Icons.person_rounded,
          page: PerfilPage(),
        ),
        _HomeNavItem(
          id: 'lideres',
          iconOutlined: Icons.groups_2_outlined,
          iconSelected: Icons.groups_2_rounded,
          page: LideresPage(),
        ),
        _HomeNavItem(
          id: 'relatorios',
          iconOutlined: Icons.file_download_outlined,
          iconSelected: Icons.file_download_rounded,
          page: RelatoriosPage(),
        ),
      ];
    }

    return const [
      _HomeNavItem(
        id: 'cadastrados',
        iconOutlined: Icons.groups_outlined,
        iconSelected: Icons.groups_rounded,
        page: CadastradosPage(showProfileInHeader: true),
      ),
      _HomeNavItem(
        id: 'feed',
        iconOutlined: Icons.article_outlined,
        iconSelected: Icons.article_rounded,
        page: FeedPage(),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(kAppSystemUiOverlay);
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final admin = await isAdminLogado();
    if (!mounted) return;
    setState(() {
      _isAdmin = admin;
      _carregando = false;
    });
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _navItemButton({
    required _HomeNavItem item,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Icon(
          selected ? item.iconSelected : item.iconOutlined,
          color: selected
              ? RamosColors.secondary
              : AppColors.white.withValues(alpha: 0.75),
          size: 28,
        ),
      ),
    );
  }

  Widget _bottomBar({
    required List<_HomeNavItem> items,
    required int currentIndex,
  }) {
    return BottomAppBar(
      // Cor do sistema na safe area inferior (home indicator) — mesma da status bar
      color: RamosColors.primaryDark,
      elevation: 0,
      padding: EdgeInsets.zero,
      height: 64,
      child: Row(
        children: List.generate(items.length, (index) {
          return Expanded(
            child: _navItemButton(
              item: items[index],
              selected: currentIndex == index,
              onTap: () => _selectTab(index),
            ),
          );
        }),
      ),
    );
  }

  Widget _body() {
    final items = _items;
    final safeIndex = _currentIndex.clamp(0, items.length - 1);

    return IndexedStack(
      index: safeIndex,
      children: items.map((item) => item.page).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        backgroundColor: AppColors.grey50,
        body: appLoadingRamos(),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kAppSystemUiOverlay,
      child: Scaffold(
        backgroundColor: AppColors.grey50,
        body: _body(),
        bottomNavigationBar: _bottomBar(
          items: _items,
          currentIndex: _currentIndex,
        ),
      ),
    );
  }
}