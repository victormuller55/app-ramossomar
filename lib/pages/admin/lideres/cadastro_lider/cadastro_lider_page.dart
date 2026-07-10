import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;
import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:app_ramos_candidatura/function/validators.dart';
import 'package:app_ramos_candidatura/models/usuario_model.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/cadastro_lider/cadastro_lider_bloc.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/cadastro_lider/cadastro_lider_event.dart';
import 'package:app_ramos_candidatura/pages/admin/lideres/cadastro_lider/cadastro_lider_state.dart';
import 'package:app_ramos_candidatura/widgets/app_elevated_button.dart';
import 'package:app_ramos_candidatura/widgets/app_loading.dart';

class CadastroLiderPage extends StatefulWidget {
  final UsuarioModel? lider;

  const CadastroLiderPage({super.key, this.lider});

  @override
  State<CadastroLiderPage> createState() => _CadastroLiderPageState();
}

class _CadastroLiderPageState extends State<CadastroLiderPage> {

  final CadastroLiderBloc bloc = CadastroLiderBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AppFormField _nomeForm;
  late final AppFormField _emailForm;
  late final AppFormField _senhaForm;
  late final AppFormField _telefoneForm;

  bool _ativo = true;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.lider?.id != null && widget.lider!.id!.isNotEmpty;
    _criarCampos();
    _preencherFormulario();
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
    _senhaForm = _criarCampo(
      hint: _isEdit ? 'Nova senha (opcional)' : 'Senha',
      icon: Icons.lock_outline_rounded,
      textInputType: TextInputType.visiblePassword,
      showContent: false,
      validator: _isEdit ? validateSenhaOpcional : validateSenhaCadastro,
    );
    _telefoneForm = _criarCampo(
      hint: 'Telefone',
      icon: Icons.phone_outlined,
      textInputType: TextInputType.phone,
      textInputFormatter: AppFormFormatters.telefone,
    );
  }

  void _preencherFormulario() {
    final lider = widget.lider;
    if (lider == null) return;

    _nomeForm.controller.text = lider.nome ?? '';
    _emailForm.controller.text = lider.email ?? '';
    _telefoneForm.controller.text = formataCelular(lider.telefone ?? '');
    _ativo = lider.ativo ?? true;
  }

  String? _valorOpcional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _validarFormulario() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _salvarCadastro() {
    if (!_validarFormulario()) return;

    final lider = UsuarioModel(
      id: widget.lider?.id,
      nome: _nomeForm.value.trim(),
      email: _emailForm.value.trim(),
      senha: _valorOpcional(_senhaForm.value),
      telefone: _valorOpcional(_telefoneForm.value),
      tipo: TipoUsuario.lider,
      ativo: _ativo,
      foto: widget.lider?.foto,
    );

    bloc.add(CadastroLiderSaveEvent(lider: lider));
  }

  void _onStateChanged(CadastroLiderState state) {
    if (state is CadastroLiderSuccessState) {
      showToastSuccess(
        message: _isEdit
            ? 'Líder atualizado com sucesso'
            : 'Líder cadastrado com sucesso',
      );
      Navigator.of(context).pop(true);
      return;
    }
    if (state is CadastroLiderErrorState) {
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
            appText(
              subtitle,
              color: AppColors.grey600,
              fontSize: 12,
            ),
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

  Widget _dadosAcesso() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Dados de acesso',
          subtitle: _isEdit
              ? 'Deixe a senha em branco para manter a atual'
              : 'O líder usará e-mail e senha para entrar no app',
        ),
        _nomeForm.formulario,
        _emailForm.formulario,
        _senhaForm.formulario,
        _telefoneForm.formulario,
      ],
    );
  }

  Widget _ativoSwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Status'),
        appContainer(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          backgroundColor: AppColors.white,
          radius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: appText(
              _ativo ? 'Líder ativo' : 'Líder inativo',
              bold: true,
              color: AppColors.grey900,
              fontSize: AppFontSizes.verySmall,
            ),
            subtitle: appText(
              _ativo
                  ? 'Pode acessar o app e gerenciar cadastrados'
                  : 'Sem acesso ao app',
              color: AppColors.grey600,
              fontSize: 12,
            ),
            value: _ativo,
            activeThumbColor: RamosColors.primary,
            onChanged: (value) => setState(() => _ativo = value),
          ),
        ),
      ],
    );
  }

  Widget _formContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dadosAcesso(),
          if (_isEdit) ...[
            _sectionDivider(),
            _ativoSwitch(),
          ],
          appSizedBox(height: 24),
          appElevatedButtonRamos(
            title: _isEdit ? 'Salvar alterações' : 'Cadastrar líder',
            onTap: _salvarCadastro,
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [_formContent()],
    );
  }

  Widget _bodyBuilder() {
    return BlocConsumer<CadastroLiderBloc, CadastroLiderState>(
      bloc: bloc,
      listener: (context, state) => _onStateChanged(state),
      builder: (context, state) {
        if (state is CadastroLiderLoadingState) {
          return appLoadingRamos();
        }
        return _body();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: _isEdit ? 'Editar líder' : 'Novo líder',
      background: AppColors.grey50,
      appBarColor: RamosColors.primaryDark,
      titleColor: AppColors.white,
      drawerColor: AppColors.white,
      centerTitle: true,
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    for (final form in [_nomeForm, _emailForm, _senhaForm, _telefoneForm]) {
      form.controller.dispose();
    }
    bloc.close();
    super.dispose();
  }
}
