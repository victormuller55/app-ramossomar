import 'dart:io';

import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';
import 'package:app_ramos_candidatura/function/form_validation.dart';
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
import 'package:image_picker/image_picker.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

class CadastroPublicacaoPage extends StatefulWidget {
  final PublicacaoModel? publicacao;

  const CadastroPublicacaoPage({super.key, this.publicacao});

  @override
  State<CadastroPublicacaoPage> createState() => _CadastroPublicacaoPageState();
}

class _CadastroPublicacaoPageState extends State<CadastroPublicacaoPage> {
  final CadastroPublicacaoBloc bloc = CadastroPublicacaoBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final AppFormField _tituloForm;
  late final AppFormField _conteudoForm;

  final List<XFile> _imagens = <XFile>[];
  List<String> _imagensExistentes = <String>[];
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.publicacao?.id != null && widget.publicacao!.id!.isNotEmpty;
    _criarCampos();
    _preencherFormulario();
  }

  void _criarCampos() {
    _tituloForm = _criarCampo(
      hint: 'Título',
      icon: Icons.title_rounded,
      validator: validateTituloPublicacao,
    );
    _conteudoForm = _criarCampo(
      hint: 'Conteúdo da publicação',
      icon: Icons.notes_rounded,
      maxLines: 6,
      validator: validateConteudoPublicacao,
    );
  }

  void _preencherFormulario() {
    final pub = widget.publicacao;
    if (pub == null) return;
    _tituloForm.controller.text = pub.titulo ?? '';
    _conteudoForm.controller.text = pub.conteudo ?? '';
    _imagensExistentes = List<String>.from(pub.imagens);
  }

  Future<void> _adicionarImagens() async {
    if (_imagens.length >= 3) {
      showToastWarning(message: 'Máximo de 3 imagens por publicação');
      return;
    }

    final restantes = 3 - _imagens.length;
    final selecionadas = await _picker.pickMultiImage(limit: restantes);
    if (selecionadas.isEmpty) return;

    setState(() {
      _imagensExistentes = <String>[];
      _imagens.addAll(selecionadas.take(restantes));
    });
  }

  void _removerImagem(int index) {
    setState(() => _imagens.removeAt(index));
  }

  bool _validarFormulario() {
    return validarFormularioComFeedback(_formKey);
  }

  void _salvarCadastro() {
    if (!_validarFormulario()) return;

    final atual = widget.publicacao;
    final publicacao = PublicacaoModel(
      id: atual?.id,
      idAutor: atual?.idAutor,
      titulo: _tituloForm.value.trim(),
      conteudo: _conteudoForm.value.trim(),
    );

    bloc.add(
      CadastroPublicacaoSaveEvent(
        publicacao: publicacao,
        imagens: List<XFile>.from(_imagens),
        isEdit: _isEdit,
      ),
    );
  }

  void _onStateChanged(CadastroPublicacaoState state) {
    if (state is CadastroPublicacaoSuccessState) {
      showToastSuccess(
        message: _isEdit
            ? 'Publicação atualizada com sucesso'
            : 'Publicação criada com sucesso',
      );
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
      textInputType: textInputType ?? TextInputType.text,
      validator: validator,
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

  Widget _conteudoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_sectionHeader('Conteúdo'), _tituloForm.formulario, _conteudoForm.formulario],
    );
  }

  Widget _imagemTile(int index) {
    final file = _imagens[index];
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(file.path),
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removerImagem(index),
            child: appContainer(
              width: 26,
              height: 26,
              backgroundColor: AppColors.black.withValues(alpha: 0.55),
              radius: BorderRadius.circular(360),
              child: Icon(Icons.close_rounded, size: 16, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagemExistenteTile(String path) {
    final url = fotoUrl(path);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return appContainer(
            width: 96,
            height: 96,
            backgroundColor: AppColors.grey200,
            radius: BorderRadius.circular(14),
            child: Icon(Icons.broken_image_outlined, color: AppColors.grey600),
          );
        },
      ),
    );
  }

  Widget _botaoAdicionarImagem() {
    return GestureDetector(
      onTap: _adicionarImagens,
      child: appContainer(
        width: 96,
        height: 96,
        backgroundColor: AppColors.white,
        radius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded, color: RamosColors.primary),
            appSizedBox(height: 6),
            appText(
              'Adicionar',
              color: RamosColors.primaryDark,
              fontSize: 11,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagensSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Imagens',
          subtitle: _isEdit
              ? 'Opcional. Novas imagens substituem as atuais (até 3).'
              : 'Opcional. Até 3 imagens (JPG, PNG, WEBP ou GIF).',
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (_imagens.isEmpty)
              ..._imagensExistentes.map(_imagemExistenteTile),
            ...List.generate(_imagens.length, _imagemTile),
            if (_imagens.length < 3) _botaoAdicionarImagem(),
          ],
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
          _conteudoSection(),
          _sectionDivider(),
          _imagensSection(),
          appSizedBox(height: 24),
          appElevatedButtonRamos(
            title: _isEdit ? 'Salvar alterações' : 'Publicar',
            onTap: _salvarCadastro,
          ),
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
      title: _isEdit ? 'Editar publicação' : 'Nova publicação',
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
    for (final form in [_tituloForm, _conteudoForm]) {
      form.controller.dispose();
    }
    bloc.close();
    super.dispose();
  }
}
