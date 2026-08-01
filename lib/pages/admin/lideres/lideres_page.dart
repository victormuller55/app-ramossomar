import 'dart:async';

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
  final ScrollController _scrollController = ScrollController();
  final List<UsuarioModel> _allLideres = <UsuarioModel>[];
  final ValueNotifier<List<UsuarioModel>> _lideresNotifier = ValueNotifier<List<UsuarioModel>>([]);

  late final AppFormField _formSearch;
  Timer? _buscaDebounce;
  bool? _filtroAtivo;
  bool _temProximaPagina = false;
  bool _loadingMore = false;
  int _maxItens = 0;

  bool get _temFiltros => _filtroAtivo != null;

  @override
  void initState() {
    super.initState();
    _criarCampoBusca();
    _scrollController.addListener(_onScroll);
    _recarregar();
  }

  void _recarregar({bool forceRefresh = false}) {
    bloc.add(
      LideresLoadEvent(
        forceRefresh: forceRefresh,
        nome: _formSearch.value.trim().isEmpty ? null : _formSearch.value.trim(),
        ativo: _filtroAtivo,
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (!_temProximaPagina || _loadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      bloc.add(LideresLoadMoreEvent());
    }
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

  void _buscar(String value) {
    _buscaDebounce?.cancel();
    _buscaDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _recarregar(forceRefresh: true);
    });
  }

  void _aplicarFiltros() {
    setState(() {});
    _recarregar(forceRefresh: true);
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
    setState(() {
      _temProximaPagina = state.temProximaPagina;
      _loadingMore = state.loadingMore;
      _maxItens = state.maxItens;
      _allLideres
        ..clear()
        ..addAll(state.lideres);
    });
    _lideresNotifier.value = List.from(_allLideres);
  }

  Future<void> _atualizarLista() async {
    _recarregar(forceRefresh: true);
    await bloc.stream.firstWhere(
      (s) => s is LideresSuccessState || s is LideresErrorState,
    );
  }

  Future<void> _editarLider(UsuarioModel lider) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => CadastroLiderPage(lider: lider)));
    if (result == true && mounted) {
      _recarregar(forceRefresh: true);
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
      _recarregar(forceRefresh: true);
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
    final total = lider.totalApoiadores;
    final labelCadastrados = total == null
        ? null
        : (total == 1 ? '1 cadastrado' : '$total cadastrados');

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
                    if (labelCadastrados != null)
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
        ),
      ),
    );
  }

  Widget _loadingMoreFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(child: appLoadingRamos(size: 22)),
    );
  }

  Widget _lideresList(List<UsuarioModel> items) {
    final extra = _loadingMore ? 1 : 0;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      sliver: SliverList.separated(
        itemCount: items.length + extra,
        separatorBuilder: (context, index) => appSizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= items.length) return _loadingMoreFooter();
          return _liderCard(items[index]);
        },
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
      child: appText(
        '$_maxItens líder${_maxItens == 1 ? '' : 'es'}',
        bold: true,
        color: RamosColors.primaryDark,
        fontSize: AppFontSizes.small,
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
          width: 50,
          height: 50,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _formSearch.formulario),
          appSizedBox(width: 8),
          // Compensa o padding top interno do AppFormField.
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _botaoFiltro(),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return RefreshIndicator(
      color: RamosColors.primary,
      onRefresh: _atualizarLista,
      child: CustomScrollView(
        controller: _scrollController,
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
        if ((state is LideresLoadingState || state is LideresInitialState) &&
            _allLideres.isEmpty) {
          return appLoadingRamos();
        }
        if (state is LideresErrorState && _allLideres.isEmpty) {
          return appError(
            state.errorModel,
            function: () => _recarregar(forceRefresh: true),
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
    _buscaDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _formSearch.controller.dispose();
    _lideresNotifier.dispose();
    bloc.close();
    super.dispose();
  }
}
