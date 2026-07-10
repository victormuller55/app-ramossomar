import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:app_ramos_candidatura/function/validators.dart';
import 'package:app_ramos_candidatura/models/publicacao_model.dart';
import 'package:app_ramos_candidatura/pages/feed/cadastro_publicacao/cadastro_publicacao_bloc.dart';
import 'package:app_ramos_candidatura/pages/feed/cadastro_publicacao/cadastro_publicacao_event.dart';
import 'package:app_ramos_candidatura/pages/feed/cadastro_publicacao/cadastro_publicacao_state.dart';
import 'package:app_ramos_candidatura/widgets/app_elevated_button.dart';
import 'package:app_ramos_candidatura/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

class CadastroPublicacaoPage extends StatefulWidget {
  const CadastroPublicacaoPage({super.key});

  @override
  State<CadastroPublicacaoPage> createState() => _CadastroPublicacaoPageState();
}

class _CadastroPublicacaoPageState extends State<CadastroPublicacaoPage> {
  final CadastroPublicacaoBloc bloc = CadastroPublicacaoBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AppFormField _tituloForm;
  late final AppFormField _conteudoForm;
  late final AppFormField _midiaForm;

  String? _tipoMidia;

  @override
  void initState() {
    super.initState();
    _criarCampos();
  }

  void _criarCampos() {
    _tituloForm = _criarCampo(
      hint: 'Título',
      icon: Icons.title_rounded,
      validator: validateTituloPublicacao,
    );
    _conteudoForm = _criarCampo(
      hint: 'Conteúdo da publicação',
      icon: Icons.notes_outlined,
      maxLines: 6,
      validator: validateConteudoPublicacao,
    );
    _midiaForm = _criarCampo(
      hint: 'URL da mídia (opcional)',
      icon: Icons.link_rounded,
      textInputType: TextInputType.url,
      onChange: _onMidiaChanged,
    );
  }

  String? _valorOpcional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _detectarTipoMidia(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final lower = url.toLowerCase();
    if (lower.contains('.mp4') ||
        lower.contains('.mov') ||
        lower.contains('.webm') ||
        lower.contains('youtube') ||
        lower.contains('youtu.be') ||
        lower.contains('vimeo')) {
      return TipoMidia.video;
    }
    return TipoMidia.imagem;
  }

  void _onMidiaChanged(String value) {
    final midia = _valorOpcional(value);
    setState(() => _tipoMidia = _detectarTipoMidia(midia));
  }

  void _selectTipoMidia(String? value) {
    setState(() => _tipoMidia = value);
  }

  bool _validarFormulario() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _salvarCadastro() {
    if (!_validarFormulario()) return;

    final midia = _valorOpcional(_midiaForm.value);
    if (midia != null && (_tipoMidia == null || _tipoMidia!.isEmpty)) {
      showToastWarning(message: 'Selecione o tipo da mídia');
      return;
    }

    final publicacao = PublicacaoModel(
      titulo: _tituloForm.value.trim(),
      conteudo: _conteudoForm.value.trim(),
      midia: midia,
      tipoMidia: midia == null ? null : _tipoMidia,
    );

    bloc.add(CadastroPublicacaoSaveEvent(publicacao: publicacao));
  }

  void _onStateChanged(CadastroPublicacaoState state) {
    if (state is CadastroPublicacaoSuccessState) {
      showToastSuccess(message: 'Publicação criada com sucesso');
      Navigator.of(context).pop(true);
      return;
    }
    if (state is CadastroPublicacaoErrorState) {
      showAppErrorSnackbar(state.errorModel);
    }
  }

  AppFormField _criarCampo({
    required String hint,
    required IconData icon,
    TextInputType? textInputType,
    String? Function(String?)? validator,
    ValueChanged<String>? onChange,
    int? maxLines,
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
      validator: validator,
      onChange: onChange,
      maxLines: maxLines,
    );
  }

  Widget _sectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(title, bold: true, color: RamosColors.primaryDark, fontSize: AppFontSizes.small),
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

  Widget _tipoChip({
    required String label,
    required String value,
    required IconData icon,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () => _selectTipoMidia(value),
      child: appContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        backgroundColor: selected ? RamosColors.secondary.withValues(alpha: 0.35) : AppColors.white,
        radius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? RamosColors.primary : AppColors.grey200,
          width: selected ? 1.5 : 1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: RamosColors.primaryDark),
            appSizedBox(width: 6),
            appText(
              label,
              bold: selected,
              color: RamosColors.primaryDark,
              fontSize: AppFontSizes.verySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _conteudoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_sectionHeader('Conteúdo'), _tituloForm.formulario, _conteudoForm.formulario],
    );
  }

  Widget _midiaSection() {
    final temMidia = _valorOpcional(_midiaForm.value) != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Mídia', subtitle: 'Opcional. Informe a URL de uma imagem ou vídeo.'),
        _midiaForm.formulario,
        if (temMidia) ...[
          appSizedBox(height: 12),
          appText(
            'Tipo da mídia',
            bold: true,
            color: AppColors.grey900,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tipoChip(
                label: 'Imagem',
                value: TipoMidia.imagem,
                icon: Icons.image_outlined,
                selected: _tipoMidia == TipoMidia.imagem,
              ),
              _tipoChip(
                label: 'Vídeo',
                value: TipoMidia.video,
                icon: Icons.videocam_outlined,
                selected: _tipoMidia == TipoMidia.video,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _formContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _conteudoSection(),
          _sectionDivider(),
          _midiaSection(),
          appSizedBox(height: 24),
          appElevatedButtonRamos(title: 'Publicar', onTap: _salvarCadastro),
        ],
      ),
    );
  }

  Widget _body() {
    return ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 32), children: [_formContent()]);
  }

  Widget _bodyBuilder() {
    return BlocConsumer<CadastroPublicacaoBloc, CadastroPublicacaoState>(
      bloc: bloc,
      listener: (context, state) => _onStateChanged(state),
      builder: (context, state) {
        if (state is CadastroPublicacaoLoadingState) {
          return appLoadingRamos();
        }
        return _body();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Nova publicação',
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
    for (final form in [_tituloForm, _conteudoForm, _midiaForm]) {
      form.controller.dispose();
    }
    bloc.close();
    super.dispose();
  }
}
