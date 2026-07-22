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
import 'package:image_cropper/image_cropper.dart';
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

  XFile? _imagem;
  String? _imagemExistente;
  bool _isEdit = false;

  bool get _temImagem => _imagem != null || (_imagemExistente?.isNotEmpty == true);

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
    if (pub.imagens.isNotEmpty) {
      _imagemExistente = pub.imagens.first;
    }
  }

  Future<XFile?> _recortarImagem(String path) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      maxWidth: 1920,
      maxHeight: 1920,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar imagem',
          toolbarColor: RamosColors.primaryDark,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: RamosColors.secondary,
          statusBarLight: false,
          navBarLight: true,
          backgroundColor: AppColors.grey50,
          cropFrameColor: RamosColors.secondary,
          cropGridColor: RamosColors.secondary.withValues(alpha: 0.4),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
          cropStyle: CropStyle.rectangle,
          aspectRatioPresets: const [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Ajustar imagem',
          doneButtonTitle: 'Usar',
          cancelButtonTitle: 'Cancelar',
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: false,
          aspectRatioPickerButtonHidden: false,
          cropStyle: CropStyle.rectangle,
          aspectRatioPresets: const [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );
    if (cropped == null) return null;
    return XFile(cropped.path);
  }

  Future<void> _adicionarImagem() async {
    final selecionada = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (selecionada == null) return;

    final ajustada = await _recortarImagem(selecionada.path);
    if (ajustada == null || !mounted) return;

    setState(() {
      _imagemExistente = null;
      _imagem = ajustada;
    });
  }

  void _removerImagem() {
    setState(() {
      _imagem = null;
      _imagemExistente = null;
    });
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
        imagens: _imagem != null ? <XFile>[_imagem!] : const <XFile>[],
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

  Widget _botaoRemoverImagem() {
    return Positioned(
      top: 10,
      right: 10,
      child: GestureDetector(
        onTap: _removerImagem,
        child: appContainer(
          width: 34,
          height: 34,
          backgroundColor: AppColors.black.withValues(alpha: 0.55),
          radius: BorderRadius.circular(360),
          child: Icon(Icons.close_rounded, size: 18, color: AppColors.white),
        ),
      ),
    );
  }

  Widget _previewImagemArquivo(XFile file) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.file(
              File(file.path),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        _botaoRemoverImagem(),
      ],
    );
  }

  Widget _previewImagemExistente(String path) {
    final url = fotoUrl(path);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              url,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return appContainer(
                  width: double.infinity,
                  backgroundColor: AppColors.grey200,
                  child: Center(
                    child: Icon(Icons.broken_image_outlined, color: AppColors.grey600, size: 42),
                  ),
                );
              },
            ),
          ),
        ),
        _botaoRemoverImagem(),
      ],
    );
  }

  Widget _botaoAdicionarImagem() {
    return GestureDetector(
      onTap: _adicionarImagem,
      child: appContainer(
        width: double.infinity,
        backgroundColor: AppColors.white,
        radius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grey200),
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_rounded, color: RamosColors.primary, size: 42),
              appSizedBox(height: 10),
              appText(
                'Adicionar imagem',
                color: RamosColors.primaryDark,
                fontSize: AppFontSizes.verySmall,
                bold: true,
              ),
              appSizedBox(height: 4),
              appText(
                'Recorte e gire antes de usar',
                color: AppColors.grey600,
                fontSize: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagensSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Imagem',
          subtitle: _isEdit
              ? 'Opcional. Uma nova imagem substitui a atual.'
              : 'Opcional. Apenas 1 imagem (JPG, PNG, WEBP ou GIF).',
        ),
        if (_imagem != null)
          _previewImagemArquivo(_imagem!)
        else if (_imagemExistente != null)
          _previewImagemExistente(_imagemExistente!)
        else
          _botaoAdicionarImagem(),
        if (_temImagem) ...[
          appSizedBox(height: 12),
          GestureDetector(
            onTap: _adicionarImagem,
            child: appText(
              'Trocar imagem',
              bold: true,
              color: RamosColors.primary,
              fontSize: AppFontSizes.verySmall,
            ),
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
