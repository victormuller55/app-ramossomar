import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:app_ramos_candidatura/models/apoiador_model.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_bloc.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_event.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastrados_state.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastro_pessoa/cadastro_pessoa_page.dart';
import 'package:app_ramos_candidatura/pages/login_page/entrar_page.dart';
import 'package:app_ramos_candidatura/pages/perfil/perfil_page.dart';
import 'package:app_ramos_candidatura/widgets/app_confirm_dialog.dart';
import 'package:app_ramos_candidatura/widgets/app_loading.dart';
import 'package:app_ramos_candidatura/widgets/empty.dart';
import 'package:app_ramos_candidatura/widgets/ramos_add_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

class CadastradosPage extends StatefulWidget {
  final bool showProfileInHeader;

  const CadastradosPage({super.key, this.showProfileInHeader = false});

  @override
  State<CadastradosPage> createState() => _CadastradosPageState();
}

class _CadastradosPageState extends State<CadastradosPage> {

  final CadastradosBloc bloc = CadastradosBloc();
  final List<ApoiadorModel> _allApoiadores = <ApoiadorModel>[];
  final ValueNotifier<List<ApoiadorModel>> _apoiadoresNotifier = ValueNotifier<List<ApoiadorModel>>([]);

  late final AppFormField _formSearch;

  UsuarioModel? _usuario;

  @override
  void initState() {
    super.initState();
    _criarCampoBusca();
    bloc.add(CadastradosLoadEvent());
  }

  void _criarCampoBusca() {
    _formSearch = AppFormField(
      context: context,
      hint: 'Buscar por nome, cidade, telefone...',
      icon: const Icon(Icons.search_rounded),
      iconColor: RamosColors.primary,
      inputColor: AppColors.grey900,
      hintColor: AppColors.grey600,
      backgroundColor: AppColors.white,
      borderColor: AppColors.grey200,
      hoverBorderColor: RamosColors.primary,
      radius: 16,
      onChange: _buscar,
    );
  }

  String _labelIntencaoVoto(String? value) {
    switch (value) {
      case IntencaoVoto.confirmado:
        return 'Confirmado';
      case IntencaoVoto.apoiador:
        return 'Apoiador';
      case IntencaoVoto.simpatizante:
        return 'Simpatizante';
      case IntencaoVoto.indeciso:
        return 'Indeciso';
      default:
        return value ?? '—';
    }
  }

  Color _corIntencaoVoto(String? value) {
    switch (value) {
      case IntencaoVoto.confirmado:
        return const Color(0xFF15803D);
      case IntencaoVoto.apoiador:
        return RamosColors.primary;
      case IntencaoVoto.simpatizante:
        return const Color(0xFFCA8A04);
      case IntencaoVoto.indeciso:
        return AppColors.grey600;
      default:
        return AppColors.grey600;
    }
  }

  String _iniciaisNome(String? nome) {
    final parts = (nome ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _contatoOuCidade(ApoiadorModel apoiador) {
    final contato = apoiador.contatoPrincipal;
    if (contato.isNotEmpty) return contato;
    if (apoiador.cidade?.isNotEmpty == true) return apoiador.cidade!;
    return 'Sem contato';
  }

  List<ApoiadorModel> _filtrarApoiadores(List<ApoiadorModel> items, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return List.from(items);

    return items.where((a) {
      final nome = (a.nome ?? '').toLowerCase();
      final cidade = (a.cidade ?? '').toLowerCase();
      final telefone = a.contatoPrincipal.toLowerCase();
      final cpf = (a.cpf ?? '').toLowerCase();
      final lider = (a.nomeLider ?? '').toLowerCase();
      return nome.contains(normalized) ||
          cidade.contains(normalized) ||
          telefone.contains(normalized) ||
          cpf.contains(normalized) ||
          lider.contains(normalized);
    }).toList();
  }

  void _buscar(String value) {
    _apoiadoresNotifier.value = _filtrarApoiadores(_allApoiadores, value);
  }

  void _aplicarSucesso(CadastradosSuccessState state) {
    _usuario = state.usuario;
    _allApoiadores
      ..clear()
      ..addAll(state.apoiadores);
    _buscar(_formSearch.value);
  }

  Future<void> _logout() async {
    final confirm = await showAppConfirmDialog(
      context,
      title: 'Sair',
      message: 'Deseja encerrar a sessão e voltar para o login?',
      icon: Icons.logout_rounded,
      confirmLabel: 'Sair',
      destructive: true,
    );
    if (confirm != true) return;
    await clearToken();
    open(screen: const LoginPage(), closePrevious: true);
  }

  Future<void> _atualizarLista() async {
    bloc.add(CadastradosLoadEvent(forceRefresh: true));
    await bloc.stream.firstWhere((s) => s is! CadastradosLoadingState);
  }

  Future<void> _editarApoiador(ApoiadorModel apoiador) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => CadastroPessoaPage(apoiador: apoiador)));
    if (result == true && mounted) {
      bloc.add(CadastradosLoadEvent(forceRefresh: true));
    }
  }

  Future<void> _excluirApoiador(ApoiadorModel apoiador) async {
    final confirm = await showAppConfirmDialog(
      context,
      title: 'Excluir cadastro',
      message: 'Deseja excluir ${apoiador.nome ?? 'este cadastro'}?',
      icon: Icons.delete_outline_rounded,
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirm != true) return;
    bloc.add(CadastradosDeleteEvent(id: apoiador.id!));
  }

  void _abrirPerfil() {
    open(screen: const PerfilPage(showBackButton: true));
  }

  Future<void> _adicionarApoiador() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CadastroPessoaPage()));
    if (result == true && mounted) {
      bloc.add(CadastradosLoadEvent(forceRefresh: true));
    }
  }

  void _onStateChanged(CadastradosState state) {
    if (state is CadastradosSuccessState) {
      _aplicarSucesso(state);
    }
    if (state is CadastradosDeleteSuccessState) {
      showToastSuccess(message: 'Cadastro excluído com sucesso');
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

  Widget _initialsAvatar({required String nome, required double size, required double textSize}) {
    return appContainer(
      width: size,
      height: size,
      radius: BorderRadius.circular(360),
      gradient: LinearGradient(
        colors: [RamosColors.primary.withValues(alpha: 0.85), RamosColors.primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Center(
        child: appText(
          _iniciaisNome(nome),
          color: AppColors.white,
          bold: true,
          fontSize: textSize,
          fontFamily: 'Segoe UI',
        ),
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

  Widget _profileEditBadge() {
    return appContainer(
      width: 24,
      height: 24,
      backgroundColor: RamosColors.secondary,
      radius: BorderRadius.circular(360),
      border: Border.all(color: AppColors.white, width: 2),
      child: Icon(Icons.edit_rounded, size: 12, color: AppColors.black),
    );
  }

  Widget _profileAvatar() {
    final foto = fotoUrl(_usuario?.foto);
    final nome = _usuario?.nome ?? '?';

    return Stack(
      children: [
        appContainer(
          width: 64,
          height: 64,
          radius: BorderRadius.circular(360),
          gradient: AppGradients.primary,
          border: Border.all(color: RamosColors.secondary, width: 2),
          child: ClipOval(
            child: foto.isNotEmpty
                ? Image.network(
                    foto,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _initialsAvatar(nome: nome, size: 64, textSize: 22);
                    },
                  )
                : _initialsAvatar(nome: nome, size: 64, textSize: 22),
          ),
        ),
        Positioned(right: 0, bottom: 0, child: _profileEditBadge()),
      ],
    );
  }

  Widget _profileCount() {
    return appContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: AppColors.grey100,
      radius: BorderRadius.circular(16),
      child: Column(
        children: [
          const Icon(Icons.groups_rounded, color: RamosColors.primary, size: 20),
          appSizedBox(height: 4),
          appText(
            _allApoiadores.length.toString().padLeft(3, '0'),
            bold: true,
            color: RamosColors.primaryDark,
            fontSize: AppFontSizes.verySmall,
          ),
        ],
      ),
    );
  }

  Widget _profileInfo() {
    final isAdmin = _usuario?.isAdmin ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        appText(
          _usuario?.nome ?? 'Usuário',
          bold: true,
          color: RamosColors.primaryDark,
          fontSize: AppFontSizes.small,
          maxLines: 1,
          overflow: true,
        ),
        appSizedBox(height: 2),
        appText(
          _usuario?.email ?? '',
          color: AppColors.grey600,
          fontSize: AppFontSizes.verySmall,
          maxLines: 1,
          overflow: true,
        ),
        appSizedBox(height: 6),
        _chip(
          label: isAdmin ? 'Administrador' : 'Líder',
          color: isAdmin ? const Color(0xFF5A7A12) : RamosColors.primary,
        ),
      ],
    );
  }

  Widget _profileCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: appContainer(
        padding: const EdgeInsets.all(16),
        backgroundColor: AppColors.white,
        radius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.grey200),
        shadow: BoxShadow(
          color: RamosColors.primary.withValues(alpha: 0.1),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        child: Row(
          children: [
            _profileAvatar(),
            appSizedBox(width: 14),
            Expanded(child: _profileInfo()),
            appSizedBox(width: 8),
            _profileCount(),
          ],
        ),
      ),
    );
  }

  Widget _listHeader() {
    final isAdmin = _usuario?.isAdmin ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          appText(
            isAdmin ? 'Todos os cadastrados' : 'Seus cadastrados',
            bold: true,
            color: AppColors.grey900,
            fontSize: AppFontSizes.small,
          ),
          const Spacer(),
          ValueListenableBuilder<List<ApoiadorModel>>(
            valueListenable: _apoiadoresNotifier,
            builder: (context, items, child) {
              return appText(
                '${items.length}',
                color: AppColors.grey600,
                fontSize: AppFontSizes.verySmall,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _apoiadorInfo(ApoiadorModel apoiador) {
    final isAdmin = _usuario?.isAdmin ?? false;
    final contato = apoiador.contatoPrincipal;
    final detalhes = contato.isNotEmpty ? formataCelular(contato) : _contatoOuCidade(apoiador);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        appText(
          apoiador.nome ?? 'Sem nome',
          bold: true,
          color: AppColors.grey900,
          fontSize: AppFontSizes.verySmall,
          maxLines: 1,
          overflow: true,
        ),
        appSizedBox(height: 3),
        appText(detalhes, color: AppColors.grey600, fontSize: 12, maxLines: 1, overflow: true),
        appSizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _chip(
              label: _labelIntencaoVoto(apoiador.intencaoVoto),
              color: _corIntencaoVoto(apoiador.intencaoVoto),
            ),
            if (isAdmin && (apoiador.nomeLider?.isNotEmpty ?? false))
              _chip(label: apoiador.nomeLider!, color: RamosColors.primary),
          ],
        ),
      ],
    );
  }

  Widget _apoiadorCard(ApoiadorModel apoiador) {
    return appContainer(
      padding: const EdgeInsets.all(14),
      backgroundColor: AppColors.white,
      radius: BorderRadius.circular(18),
      child: Row(
        children: [
          _initialsAvatar(nome: apoiador.nome ?? '?', size: 48, textSize: 16),
          appSizedBox(width: 12),
          Expanded(child: _apoiadorInfo(apoiador)),
          appSizedBox(width: 8),
          _actionButton(
            icon: Icons.edit_rounded,
            background: RamosColors.secondary.withValues(alpha: 0.35),
            iconColor: RamosColors.primaryDark,
            onTap: () => _editarApoiador(apoiador),
          ),
          appSizedBox(width: 8),
          _actionButton(
            icon: Icons.delete_outline_rounded,
            background: AppColors.red.withValues(alpha: 0.12),
            iconColor: AppColors.red,
            onTap: () => _excluirApoiador(apoiador),
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
          title: 'Nenhum cadastrado encontrado',
          subtitle: _formSearch.value.trim().isEmpty
              ? 'Toque no + para cadastrar a primeira pessoa.'
              : 'Tente outro termo de busca.',
          icon: Icons.people_outline_rounded,
        ),
      ),
    );
  }

  Widget _apoiadoresList(List<ApoiadorModel> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => appSizedBox(height: 12),
        itemBuilder: (context, index) => _apoiadorCard(items[index]),
      ),
    );
  }

  Widget _listSliver() {
    return ValueListenableBuilder<List<ApoiadorModel>>(
      valueListenable: _apoiadoresNotifier,
      builder: (context, items, child) {
        if (items.isEmpty) return _emptyState();
        return _apoiadoresList(items);
      },
    );
  }

  Widget _searchField() {
    return Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 8), child: _formSearch.formulario);
  }

  Widget _body() {
    return RefreshIndicator(
      color: RamosColors.primary,
      onRefresh: _atualizarLista,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _profileCard()),
          SliverToBoxAdapter(child: _searchField()),
          SliverToBoxAdapter(child: _listHeader()),
          _listSliver(),
        ],
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocConsumer<CadastradosBloc, CadastradosState>(
      bloc: bloc,
      listener: (context, state) => _onStateChanged(state),
      builder: (context, state) {
        if (state is CadastradosLoadingState || state is CadastradosInitialState) {
          return appLoadingRamos();
        }
        if (state is CadastradosErrorState) {
          return appError(
            state.errorModel,
            function: () => bloc.add(CadastradosLoadEvent(forceRefresh: true)),
          );
        }
        return _body();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Cadastrados',
      background: AppColors.grey50,
      appBarColor: RamosColors.primaryDark,
      titleColor: AppColors.white,
      drawerColor: AppColors.white,
      hideBackIcon: true,
      centerTitle: true,
      floatingActionButton: ramosAddFab(onTap: _adicionarApoiador),
      actions: [
        if (widget.showProfileInHeader)
          IconButton(
            onPressed: _abrirPerfil,
            icon: Icon(Icons.person_outline_rounded, color: AppColors.white),
          ),
        IconButton(
          onPressed: _logout,
          icon: Icon(Icons.logout_rounded, color: AppColors.white),
        ),
      ],
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    _formSearch.controller.dispose();
    _apoiadoresNotifier.dispose();
    bloc.close();
    super.dispose();
  }
}
