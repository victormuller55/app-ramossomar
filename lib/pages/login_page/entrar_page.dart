import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/app_theme.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/function/form_validation.dart';
import 'package:app_ramos_candidatura/function/validators.dart';
import 'package:app_ramos_candidatura/pages/login_page/entrar_bloc.dart';
import 'package:app_ramos_candidatura/pages/login_page/entrar_event.dart';
import 'package:app_ramos_candidatura/pages/login_page/entrar_state.dart';
import 'package:app_ramos_candidatura/widgets/app_elevated_button.dart';
import 'package:app_ramos_candidatura/widgets/app_loading.dart';
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

  /// Status bar verde + navigation bar branca (login).
  static const SystemUiOverlayStyle loginSystemUi = SystemUiOverlayStyle(
    statusBarColor: RamosColors.primaryDark,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: Color(0xFFFFFFFF),
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Color(0xFFFFFFFF),
    systemNavigationBarContrastEnforced: false,
  );

  void _aplicarSystemUi() {
    SystemChrome.setSystemUIOverlayStyle(loginSystemUi);
  }

  @override
  void initState() {
    super.initState();
    _aplicarSystemUi();
    WidgetsBinding.instance.addPostFrameCallback((_) => _aplicarSystemUi());
    _criarCampos();
  }

  void _criarCampos() {
    _loginForm = LoginFormField(
      hint: AppStrings.digiteSeuEmail,
      icon: Icons.email_rounded,
      validator: validateEmail,
    );

    _passwordForm = LoginFormField(
      hint: AppStrings.digiteSuaSenha,
      icon: Icons.lock_rounded,
      obscureText: true,
      validator: validateSenhaLogin,
    );
  }

  bool _validarFormulario() {
    return validarFormularioComFeedback(_formKey);
  }

  void _salvarLogin() {
    if (!_validarFormulario()) return;
    bloc.add(EntrarLoginEvent(_loginForm.value, _passwordForm.value));
  }

  Widget _brandHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
      child: appLogoRamos(alignment: Alignment.center),
    );
  }

  Widget _loginSheet() {
    return appContainer(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      backgroundColor: AppColors.white,
      radius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: appContainer(
              width: 42,
              height: 4,
              radius: BorderRadius.circular(8),
              backgroundColor: AppColors.grey200,
            ),
          ),
          appSizedBox(height: 18),
          appText(
            'Acesse sua conta',
            bold: true,
            color: RamosColors.primaryDark,
            fontSize: AppFontSizes.medium,
          ),
          appSizedBox(height: 6),
          appText(
            'Utilize suas credenciais de administrador ou líder para entrar. Caso ainda não possua acesso, solicite ao administrador do aplicativo.',
            color: AppColors.grey600,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: 18),
          _loginForm.formulario,
          _passwordForm.formulario,
          appSizedBox(height: 20),
          appElevatedButtonRamos(
            title: AppStrings.entrar,
            onTap: _salvarLogin,
            height: 52,
          ),
          appSizedBox(height: 28),
          appText(
            'Powered by Convertix',
            color: AppColors.grey600,
            fontSize: AppFontSizes.verySmall,
            textAlign: TextAlign.center,
          ),
          appSizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _loading() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: loginSystemUi,
      child: appContainer(
        width: double.infinity,
        height: double.infinity,
        gradient: AppGradients.loginPanel,
        child: appLoadingRamos(color: RamosColors.secondary),
      ),
    );
  }

  Widget _body() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: loginSystemUi,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: appContainer(
          width: double.infinity,
          height: double.infinity,
          gradient: AppGradients.loginPanel,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _brandHeader(),
                      _loginSheet(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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
    _aplicarSystemUi();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: loginSystemUi,
      child: scaffold(
        appBarColor: RamosColors.primaryDark,
        title: AppStrings.vazio,
        showAppBar: false,
        background: RamosColors.primaryDark,
        hideBackIcon: true,
        body: _bodyBuilder(),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(kAppSystemUiOverlay);
    _loginForm.controller.dispose();
    _loginForm.focusNode.dispose();
    _passwordForm.controller.dispose();
    _passwordForm.focusNode.dispose();
    bloc.close();
    super.dispose();
  }
}
