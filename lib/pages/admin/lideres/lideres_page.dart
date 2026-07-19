import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/cadastro_lider/cadastro_lider_page.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/lideres_bloc.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/lideres_event.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/lideres_state.dart';
import 'package:app_ramos_candidatura/widgets/app_confirm_dialog.dart';
import 'package:app_ramos_candidatura/widgets/app_elevated_button.dart';
import 'package:app_ramos_candidatura/widgets/app_loading.dart';
import 'package:app_ramos_candidatura/widgets/empty.dart';
import 'package:app_ramos_candidatura/widgets/ramos_add_fab.dart';
import 'package:app_ramos_candidatura/widgets/ramos_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

class LideresPage extends StatefulWidget {
  const LideresPage({super.key});

  @override
  State<LideresPage> createState() => _LideresPageState();
}

class _LideresPageState extends State<LideresPage> {
  final LideresBloc bloc = LideresBloc();
  final List<UsuarioModel> _allLideres = <UsuarioModel>[];
  final ValueNotifier<List<UsuarioModel>> _lideresNotifier = ValueNotifier<List<UsuarioModel>>([]);

  late final AppFormField _formSearch;
  bool? _filtroAtivo;

  bool get _temFiltros => _filtroAtivo != null;

  @override
  void initState() {
    super.initState();
    _criarCampoBusca();
    bloc.add(LideresLoadEvent());
  }

  void _criarCampoBusca() {
    _formSearch = AppFormField(
      context: context,
      hint: 'Buscar por nome, e-mail, telefone...',
      icon: const Icon(Icons.search_rounded),
      iconColor: RamosColors.primary,
      inputColor: AppColors.grey900,
      hintColor: AppColors.grey600,
      backgroundColor: AppColors.white,
      borderColor: AppColors.grey200,
      hoverBorderColor: RamosColors.primary,
      radius: 16,
      textInputType: TextInputType.text,
      onChange: _buscar,
    );
  }

  String _iniciaisNome(String? nome) {
    final parts = (nome ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  List<UsuarioModel> _filtrarLideres(List<UsuarioModel> items, String query) {
    final normalized = query.trim().toLowerCase();

    return items.where((u) {
      if (_filtroAtivo != null && (u.ativo ?? true) != _filtroAtivo) {
        return false;
      }
      if (normalized.isEmpty) return true;

      final nome = (u.nome ?? '').toLowerCase();
      final email = (u.email ?? '').toLowerCase();
      final telefone = (u.telefone ?? '').toLowerCase();
      return nome.contains(normalized) ||
          email.contains(normalized) ||
          telefone.contains(normalized);
    }).toList();
  }

  void _buscar(String value) {
    _lideresNotifier.value = _filtrarLideres(_allLideres, value);
  }

  void _aplicarFiltros() {
    _buscar(_formSearch.value);
    setState(() {});
  }

  String _labelStatus(bool? value) {
    if (value == true) return 'Ativos';
    if (value == false) return 'Inativos';
    return 'Todos';
  }

  Future<void> _abrirFiltros() async {
    var statusDraft = _filtroAtivo;

    final aplicado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: appContainer(
                        width: 40,
                        height: 4,
                        backgroundColor: AppColors.grey200,
                        radius: BorderRadius.circular(20),
                      ),
                    ),
                    appSizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: appText(
                            'Filtros',
                            bold: true,
                            color: RamosColors.primaryDark,
                            fontSize: AppFontSizes.small,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: Icon(Icons.close_rounded, color: AppColors.grey600),
                        ),
                      ],
                    ),
                    appText(
                      'Status do líder',
                      color: AppColors.grey600,
                      fontSize: 12,
                    ),
                    appSizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <bool?>[null, true, false].map((opcao) {
                        final selected = statusDraft == opcao;
                        return GestureDetector(
                          onTap: () => setModalState(() => statusDraft = opcao),
                          child: appContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            backgroundColor: selected
                                ? RamosColors.secondary.withValues(alpha: 0.35)
                                : AppColors.white,
                            radius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? RamosColors.primary : AppColors.grey200,
                              width: selected ? 1.5 : 1,
                            ),
                            child: appText(
                              _labelStatus(opcao),
                              bold: selected,
                              color: RamosColors.primaryDark,
                              fontSize: AppFontSizes.verySmall,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    appSizedBox(height: 24),
                    appElevatedButtonRamos(
                      title: 'Aplicar filtros',
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                    appSizedBox(height: 10),
                    appElevatedButtonRamos(
                      title: 'Limpar',
                      primary: false,
                      onTap: () => setModalState(() => statusDraft = null),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (aplicado == true && mounted) {
      _filtroAtivo = statusDraft;
      _aplicarFiltros();
    }
  }

  void _aplicarSucesso(LideresSuccessState state) {
    _allLideres
      ..clear()
      ..addAll(state.lideres);
    _buscar(_formSearch.value);
  }

  Future<void> _atualizarLista() async {
    bloc.add(LideresLoadEvent(forceRefresh: true));
    await bloc.stream.firstWhere((s) => s is! LideresLoadingState);
  }

  Future<void> _editarLider(UsuarioModel lider) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => CadastroLiderPage(lider: lider)));
    if (result == true && mounted) {
      bloc.add(LideresLoadEvent(forceRefresh: true));
    }
  }

  Future<void> _inativarLider(UsuarioModel lider) async {
    final confirm = await showAppConfirmDialog(
      context,
      title: 'Inativar líder',
      message: 'Deseja inativar ${lider.nome ?? 'este líder'}?',
      icon: Icons.person_off_outlined,
      confirmLabel: 'Inativar',
      destructive: true,
    );
    if (confirm != true) return;
    bloc.add(LideresDeleteEvent(id: lider.id!));
  }

  Future<void> _adicionarLider() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CadastroLiderPage()));
    if (result == true && mounted) {
      bloc.add(LideresLoadEvent(forceRefresh: true));
    }
  }

  void _onStateChanged(LideresState state) {
    if (state is LideresSuccessState) {
      _aplicarSucesso(state);
    }
    if (state is LideresDeleteSuccessState) {
      showToastSuccess(message: 'Líder inativado com sucesso');
    }
  }

  Widget _chip({required String label, required Color color}) {
    return appContainer(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      backgroundColor: color.withValues(alpha: 0.12),
      radius: BorderRadius.circular(20),
      child: appText(label, color: color, bold: true, fontSize: 10),
    );
  }

  Widget _avatarIniciais(String nome) {
    return Center(
      child: appText(_iniciaisNome(nome), color: AppColors.white, bold: true, fontSize: 16),
    );
  }

  Widget _avatar(UsuarioModel lider) {
    final foto = fotoUrl(lider.foto);
    final nome = lider.nome ?? '?';

    return appContainer(
      width: 48,
      height: 48,
      radius: BorderRadius.circular(360),
      gradient: LinearGradient(
        colors: [RamosColors.primary.withValues(alpha: 0.85), RamosColors.primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: ClipOval(
        child: foto.isNotEmpty
            ? Image.network(
                foto,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _avatarIniciais(nome),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const RamosShimmer(
                    width: 48,
                    height: 48,
                    borderRadius: BorderRadius.all(Radius.circular(360)),
                  );
                },
              )
            : _avatarIniciais(nome),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color background,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: appContainer(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }

  Widget _liderCard(UsuarioModel lider) {
    final ativo = lider.ativo ?? true;
    final telefone = (lider.telefone ?? '').trim();
    final detalhe = telefone.isNotEmpty ? formataCelular(telefone) : (lider.email ?? 'Sem e-mail');
    final total = lider.totalApoiadores ?? 0;
    final labelCadastrados = total == 1 ? '1 cadastrado' : '$total cadastrados';

    return appContainer(
      padding: const EdgeInsets.all(14),
      backgroundColor: AppColors.white,
      radius: BorderRadius.circular(18),
      child: Row(
        children: [
          _avatar(lider),
          appSizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appText(
                  lider.nome ?? 'Sem nome',
                  bold: true,
                  color: AppColors.grey900,
                  fontSize: AppFontSizes.verySmall,
                  maxLines: 1,
                  overflow: true,
                ),
                appSizedBox(height: 3),
                appText(
                  detalhe,
                  color: AppColors.grey600,
                  fontSize: 12,
                  maxLines: 1,
                  overflow: true,
                ),
                if (telefone.isNotEmpty && (lider.email?.isNotEmpty ?? false)) ...[
                  appSizedBox(height: 2),
                  appText(
                    lider.email!,
                    color: AppColors.grey600,
                    fontSize: 11,
                    maxLines: 1,
                    overflow: true,
                  ),
                ],
                appSizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _chip(
                      label: ativo ? 'Ativo' : 'Inativo',
                      color: ativo ? RamosColors.primary : AppColors.grey600,
                    ),
                    _chip(
                      label: labelCadastrados,
                      color: RamosColors.primaryDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          appSizedBox(width: 8),
          _actionButton(
            icon: Icons.edit_rounded,
            background: RamosColors.secondary.withValues(alpha: 0.35),
            iconColor: RamosColors.primaryDark,
            onTap: () => _editarLider(lider),
          ),
          appSizedBox(width: 8),
          _actionButton(
            icon: Icons.delete_outline_rounded,
            background: AppColors.red.withValues(alpha: 0.12),
            iconColor: AppColors.red,
            onTap: () => _inativarLider(lider),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: emptyMessage(
          title: 'Nenhum líder encontrado',
          subtitle: _formSearch.value.trim().isEmpty && !_temFiltros
              ? 'Toque no + para cadastrar o primeiro líder.'
              : 'Tente outro termo de busca ou ajuste os filtros.',
          icon: Icons.groups_2_outlined,
        ),
      ),
    );
  }

  Widget _lideresList(List<UsuarioModel> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => appSizedBox(height: 12),
        itemBuilder: (context, index) => _liderCard(items[index]),
      ),
    );
  }

  Widget _listSliver() {
    return ValueListenableBuilder<List<UsuarioModel>>(
      valueListenable: _lideresNotifier,
      builder: (context, items, child) {
        if (items.isEmpty) return _emptyState();
        return _lideresList(items);
      },
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: ValueListenableBuilder<List<UsuarioModel>>(
        valueListenable: _lideresNotifier,
        builder: (context, items, child) {
          return appText(
            '${items.length} líder${items.length == 1 ? '' : 'es'}',
            bold: true,
            color: RamosColors.primaryDark,
            fontSize: AppFontSizes.small,
          );
        },
      ),
    );
  }

  Widget _botaoFiltro() {
    return Material(
      color: _temFiltros ? RamosColors.secondary.withValues(alpha: 0.35) : AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _abrirFiltros,
        borderRadius: BorderRadius.circular(16),
        child: appContainer(
          width: 52,
          height: 52,
          border: Border.all(
            color: _temFiltros ? RamosColors.primary : AppColors.grey200,
            width: _temFiltros ? 1.5 : 1,
          ),
          radius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.tune_rounded, color: RamosColors.primaryDark, size: 22),
              if (_temFiltros)
                Positioned(
                  top: 10,
                  right: 10,
                  child: appContainer(
                    width: 8,
                    height: 8,
                    backgroundColor: RamosColors.primary,
                    radius: BorderRadius.circular(20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(child: _formSearch.formulario),
          appSizedBox(width: 8),
          _botaoFiltro(),
        ],
      ),
    );
  }

  Widget _body() {
    return RefreshIndicator(
      color: RamosColors.primary,
      onRefresh: _atualizarLista,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _searchField()),
          SliverToBoxAdapter(child: _header()),
          _listSliver(),
        ],
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocConsumer<LideresBloc, LideresState>(
      bloc: bloc,
      listener: (context, state) => _onStateChanged(state),
      builder: (context, state) {
        if (state is LideresLoadingState || state is LideresInitialState) {
          return appLoadingRamos();
        }
        if (state is LideresErrorState) {
          return appError(
            state.errorModel,
            function: () => bloc.add(LideresLoadEvent(forceRefresh: true)),
          );
        }
        return _body();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Líderes',
      background: AppColors.grey50,
      appBarColor: RamosColors.primaryDark,
      titleColor: AppColors.white,
      drawerColor: AppColors.white,
      hideBackIcon: true,
      centerTitle: true,
      floatingActionButton: ramosAddFab(
        onTap: _adicionarLider,
        heroTag: 'fab-lideres-add',
      ),
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    _formSearch.controller.dispose();
    _lideresNotifier.dispose();
    bloc.close();
    super.dispose();
  }
}
