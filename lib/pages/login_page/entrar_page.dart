import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/function/validators.dart';
import 'package:app_ramos_candidatura/pages/login_page/entrar_bloc.dart';
import 'package:app_ramos_candidatura/pages/login_page/entrar_event.dart';
import 'package:app_ramos_candidatura/pages/login_page/entrar_state.dart';
import 'package:app_ramos_candidatura/widgets/app_elevated_button.dart';
import 'package:app_ramos_candidatura/widgets/app_logo.dart';
import 'package:app_ramos_candidatura/widgets/login/login_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final EntrarBloc bloc = EntrarBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final LoginFormField _loginForm;
  late final LoginFormField _passwordForm;

  @override
  void initState() {
    super.initState();
    _criarCampos();
  }

  void _criarCampos() {
    _loginForm = LoginFormField(
      hint: AppStrings.digiteSeuEmail,
      icon: Icons.email,
      validator: validateEmail,
    );

    _passwordForm = LoginFormField(
      hint: AppStrings.digiteSuaSenha,
      icon: Icons.lock,
      obscureText: true,
      validator: validateSenhaLogin,
    );
  }

  bool _validarFormulario() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _salvarLogin() {
    if (!_validarFormulario()) return;
    bloc.add(EntrarLoginEvent(_loginForm.value, _passwordForm.value));
  }

  Widget _formHeader() {
    return Column(
      children: [
        appContainer(
          height: 200,
          width: double.infinity,
          radius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          padding: EdgeInsets.only(left: 50, right: 50),
          gradient: LinearGradient(
            colors: [RamosColors.primaryDark, RamosColors.primary],
            begin: AlignmentGeometry.topCenter,
            end: AlignmentGeometry.bottomCenter,
          ),
          child: appLogoRamos(height: 140, alignment: Alignment.center),
        ),
        appSizedBox(height: AppSpacing.big),
        appText(
          'Use suas credenciais para acessar o painel de candidatura',
          color: AppColors.grey600,
          textAlign: TextAlign.center,
        ),
        appSizedBox(height: AppSpacing.medium),
      ],
    );
  }

  Widget _loginFields() {
    return Column(children: [_loginForm.formulario, _passwordForm.formulario]);
  }

  Widget _loginButtons() {
    return Column(
      children: [
        appSizedBox(height: AppSpacing.medium),
        appElevatedButtonRamos(
          title: AppStrings.entrar,
          onTap: _salvarLogin,
          width: 360,
          height: 48,
        ),
      ],
    );
  }

  Widget _loginFooter() {
    return Column(
      children: [
        appSizedBox(height: AppSpacing.big),
        appText(
          '© Ramos ${DateTime.now().year}',
          color: AppColors.grey600,
          fontSize: AppFontSizes.verySmall,
        ),
      ],
    );
  }

  Widget _loading() {
    return appLoading(
      child: CircularProgressIndicator(color: RamosColors.secondary),
    );
  }

  Widget _body() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        children: [
          _formHeader(),
          _loginFields(),
          _loginButtons(),
          _loginFooter(),
        ],
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocBuilder<EntrarBloc, EntrarState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is EntrarLoadingState) {
          return _loading();
        }
        return _body();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      appBarColor: RamosColors.primaryDark,
      title: AppStrings.vazio,
      background: AppColors.white,
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    _loginForm.controller.dispose();
    _loginForm.focusNode.dispose();
    _passwordForm.controller.dispose();
    _passwordForm.focusNode.dispose();
    bloc.close();
    super.dispose();
  }
}
