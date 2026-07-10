import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;
import 'package:app_ramos_candidatura/app_config/app_auth.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:app_ramos_candidatura/function/validators.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/pages/login_page/entrar_page.dart';
import 'package:app_ramos_candidatura/pages/perfil/perfil_bloc.dart';
import 'package:app_ramos_candidatura/pages/perfil/perfil_event.dart';
import 'package:app_ramos_candidatura/pages/perfil/perfil_state.dart';
import 'package:app_ramos_candidatura/widgets/app_confirm_dialog.dart';
import 'package:app_ramos_candidatura/widgets/app_elevated_button.dart';
import 'package:app_ramos_candidatura/widgets/app_loading.dart';

class PerfilPage extends StatefulWidget {
  final bool showBackButton;

  const PerfilPage({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final PerfilBloc bloc = PerfilBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AppFormField _nomeForm;
  late final AppFormField _emailForm;
  late final AppFormField _telefoneForm;
  late final AppFormField _senhaForm;

  UsuarioModel? _usuario;
  bool _formsReady = false;

  @override
  void initState() {
    super.initState();
    _criarCampos();
    _formsReady = true;
    bloc.add(PerfilLoadEvent());
  }

  void _criarCampos() {
    _nomeForm = _criarCampo(
      hint: 'Nome completo',
      icon: Icons.person_outline_rounded,
      validator: validateNome,
    );
    _emailForm = _criarCampo(
      hint: 'E-mail',
      icon: Icons.email_outlined,
      textInputType: TextInputType.emailAddress,
      validator: validateEmail,
    );
    _telefoneForm = _criarCampo(
      hint: 'Telefone',
      icon: Icons.phone_outlined,
      textInputType: TextInputType.phone,
      textInputFormatter: AppFormFormatters.telefone,
    );
    _senhaForm = _criarCampo(
      hint: 'Nova senha (opcional)',
      icon: Icons.lock_outline_rounded,
      textInputType: TextInputType.visiblePassword,
      showContent: false,
      validator: validateSenhaOpcional,
    );
  }

  String? _valorOpcional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _iniciais(String? nome) {
    final parts = (nome ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _preencherFormulario(UsuarioModel usuario) {
    _usuario = usuario;
    if (!_formsReady) return;
    _nomeForm.controller.text = usuario.nome ?? '';
    _emailForm.controller.text = usuario.email ?? '';
    _telefoneForm.controller.text = formataCelular(usuario.telefone ?? '');
    _senhaForm.controller.clear();
  }

  bool _validarFormulario() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _salvarCadastro() {
    if (!_validarFormulario()) return;
    final atual = _usuario;
    if (atual?.id == null || atual!.id!.isEmpty) return;

    final usuario = UsuarioModel(
      id: atual.id,
      nome: _nomeForm.value.trim(),
      email: _emailForm.value.trim(),
      telefone: _valorOpcional(_telefoneForm.value),
      senha: _valorOpcional(_senhaForm.value),
      tipo: atual.tipo,
      ativo: atual.ativo ?? true,
      foto: atual.foto,
    );

    bloc.add(PerfilSaveEvent(usuario: usuario));
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

  void _onStateChanged(PerfilState state) {
    if (state is PerfilLoadedState) {
      _preencherFormulario(state.usuario);
      return;
    }
    if (state is PerfilSuccessState) {
      _preencherFormulario(state.usuario);
      showToastSuccess(message: 'Perfil atualizado com sucesso');
      return;
    }
    if (state is PerfilErrorState) {
      showAppErrorSnackbar(state.errorModel);
    }
  }

  AppFormField _criarCampo({
    required String hint,
    required IconData icon,
    TextInputType? textInputType,
    TextInputFormatter? textInputFormatter,
    String? Function(String?)? validator,
    bool? showContent,
  }) {
    return AppFormField(
      context: context,
      hint: hint,
      icon: Icon(icon),
      iconColor: RamosColors.primary,
      inputColor: AppColors.grey900,
      hintColor: AppColors.grey600,
      backgroundColor: AppColors.white,
      borderColor: AppColors.grey200,
      hoverBorderColor: RamosColors.primary,
      radius: 14,
      textInputType: textInputType,
      textInputFormatter: textInputFormatter,
      validator: validator,
      showContent: showContent,
    );
  }

  Widget _sectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(
            title,
            bold: true,
            color: RamosColors.primaryDark,
            fontSize: AppFontSizes.small,
          ),
          if (subtitle != null) ...[
            appSizedBox(height: 4),
            appText(subtitle, color: AppColors.grey600, fontSize: 12),
          ],
        ],
      ),
    );
  }

  Widget _sectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: AppColors.grey200, height: 1),
    );
  }

  Widget _avatarIniciais(String nome) {
    return Center(
      child: appText(
        _iniciais(nome),
        color: AppColors.white,
        bold: true,
        fontSize: 28,
      ),
    );
  }

  Widget _avatar() {
    final foto = fotoUrl(_usuario?.foto);
    final nome = _usuario?.nome ?? '?';

    return Center(
      child: appContainer(
        width: 96,
        height: 96,
        radius: BorderRadius.circular(360),
        gradient: AppGradients.primary,
        border: Border.all(color: RamosColors.secondary, width: 3),
        child: ClipOval(
          child: foto.isNotEmpty
              ? Image.network(
                  foto,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _avatarIniciais(nome);
                  },
                )
              : _avatarIniciais(nome),
        ),
      ),
    );
  }

  Widget _perfilChip() {
    final isAdmin = _usuario?.isAdmin ?? false;
    return Center(
      child: appContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        backgroundColor: (isAdmin ? const Color(0xFF5A7A12) : RamosColors.primary)
            .withValues(alpha: 0.12),
        radius: BorderRadius.circular(20),
        child: appText(
          isAdmin ? 'Administrador' : 'Líder',
          bold: true,
          color: isAdmin ? const Color(0xFF5A7A12) : RamosColors.primary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        _avatar(),
        appSizedBox(height: 14),
        appText(
          _usuario?.nome ?? 'Usuário',
          bold: true,
          color: RamosColors.primaryDark,
          fontSize: AppFontSizes.medium,
          textAlign: TextAlign.center,
        ),
        appSizedBox(height: 4),
        appText(
          _usuario?.email ?? '',
          color: AppColors.grey600,
          fontSize: 13,
          textAlign: TextAlign.center,
        ),
        appSizedBox(height: 10),
        _perfilChip(),
      ],
    );
  }

  Widget _dadosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Meus dados'),
        _nomeForm.formulario,
        _emailForm.formulario,
        _telefoneForm.formulario,
      ],
    );
  }

  Widget _senhaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Segurança',
          subtitle: 'Deixe em branco para manter a senha atual',
        ),
        _senhaForm.formulario,
      ],
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: Icon(Icons.logout_rounded, color: AppColors.red),
        label: appText(
          'Sair da conta',
          bold: true,
          color: AppColors.red,
          fontSize: AppFontSizes.verySmall,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          side: BorderSide(color: AppColors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _formContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          appSizedBox(height: 28),
          _dadosSection(),
          _sectionDivider(),
          _senhaSection(),
          appSizedBox(height: 24),
          appElevatedButtonRamos(
            title: 'Salvar alterações',
            onTap: _salvarCadastro,
          ),
          appSizedBox(height: 16),
          _logoutButton(),
        ],
      ),
    );
  }

  Widget _body() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      children: [_formContent()],
    );
  }

  Widget _bodyBuilder() {
    return BlocConsumer<PerfilBloc, PerfilState>(
      bloc: bloc,
      listener: (context, state) => _onStateChanged(state),
      builder: (context, state) {
        if (state is PerfilLoadingState || state is PerfilInitialState) {
          return appLoadingRamos();
        }
        if (state is PerfilErrorState && _usuario == null) {
          return appError(
            state.errorModel,
            function: () => bloc.add(PerfilLoadEvent()),
          );
        }
        return _body();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Perfil',
      background: AppColors.grey50,
      appBarColor: RamosColors.primaryDark,
      titleColor: AppColors.white,
      drawerColor: AppColors.white,
      hideBackIcon: !widget.showBackButton,
      centerTitle: true,
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    for (final form in [_nomeForm, _emailForm, _telefoneForm, _senhaForm]) {
      form.controller.dispose();
    }
    bloc.close();
    super.dispose();
  }
}
