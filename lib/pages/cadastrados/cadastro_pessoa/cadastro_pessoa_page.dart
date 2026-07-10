import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;
import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:app_ramos_candidatura/function/validators.dart';
import 'package:app_ramos_candidatura/function/via_cep.dart';
import 'package:app_ramos_candidatura/models/apoiador_model.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastro_pessoa/cadastro_pessoa_bloc.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastro_pessoa/cadastro_pessoa_event.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastro_pessoa/cadastro_pessoa_state.dart';
import 'package:app_ramos_candidatura/widgets/app_elevated_button.dart';
import 'package:app_ramos_candidatura/widgets/app_loading.dart';

class CadastroPessoaPage extends StatefulWidget {
  final ApoiadorModel? apoiador;

  const CadastroPessoaPage({super.key, this.apoiador});

  @override
  State<CadastroPessoaPage> createState() => _CadastroPessoaPageState();
}

class _CadastroPessoaPageState extends State<CadastroPessoaPage> {

  final CadastroPessoaBloc bloc = CadastroPessoaBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AppFormField _nomeForm;
  late final AppFormField _cpfForm;
  late final AppFormField _dataNascimentoForm;
  late final AppFormField _telefoneForm;
  late final AppFormField _whatsappForm;
  late final AppFormField _cepForm;
  late final AppFormField _enderecoForm;
  late final AppFormField _numeroForm;
  late final AppFormField _complementoForm;
  late final AppFormField _bairroForm;
  late final AppFormField _cidadeForm;
  late final AppFormField _localVotacaoForm;
  late final AppFormField _observacoesForm;

  String _intencaoVoto = IntencaoVoto.indeciso;
  bool _buscandoCep = false;
  String? _ultimoCepBuscado;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.apoiador?.id != null && widget.apoiador!.id!.isNotEmpty;
    _criarCampos();
    _preencherFormulario();
  }

  void _criarCampos() {
    _nomeForm = _criarCampo(
      hint: 'Nome completo',
      icon: Icons.person_outline_rounded,
      validator: validateNome,
    );
    _cpfForm = _criarCampo(
      hint: 'CPF',
      icon: Icons.badge_outlined,
      textInputType: TextInputType.number,
      textInputFormatter: AppFormFormatters.cpf,
      validator: validateCpf,
    );
    _dataNascimentoForm = _criarCampo(
      hint: 'Data de nascimento',
      icon: Icons.calendar_today_outlined,
      textInputType: TextInputType.number,
      textInputFormatter: AppFormFormatters.data,
      validator: validateDataNascimento,
    );
    _telefoneForm = _criarCampo(
      hint: 'Telefone',
      icon: Icons.phone_outlined,
      textInputType: TextInputType.phone,
      textInputFormatter: AppFormFormatters.telefone,
    );
    _whatsappForm = _criarCampo(
      hint: 'WhatsApp',
      icon: Icons.chat_outlined,
      textInputType: TextInputType.phone,
      textInputFormatter: AppFormFormatters.telefone,
    );
    _cepForm = _criarCampo(
      hint: 'CEP',
      icon: Icons.markunread_mailbox_outlined,
      textInputType: TextInputType.number,
      textInputFormatter: AppFormFormatters.cep,
      onChange: _onCepChanged,
    );
    _enderecoForm = _criarCampo(
      hint: 'Endereço',
      icon: Icons.home_outlined,
    );
    _numeroForm = _criarCampo(
      hint: 'Número',
      icon: Icons.tag_outlined,
      textInputType: TextInputType.text,
    );
    _complementoForm = _criarCampo(
      hint: 'Complemento',
      icon: Icons.apartment_outlined,
    );
    _bairroForm = _criarCampo(
      hint: 'Bairro',
      icon: Icons.location_city_outlined,
    );
    _cidadeForm = _criarCampo(
      hint: 'Cidade',
      icon: Icons.location_on_outlined,
    );
    _localVotacaoForm = _criarCampo(
      hint: 'Local de votação',
      icon: Icons.how_to_vote_outlined,
    );
    _observacoesForm = _criarCampo(
      hint: 'Observações',
      icon: Icons.notes_outlined,
      maxLines: 3,
    );
  }

  void _preencherFormulario() {
    final apo = widget.apoiador;
    if (apo == null) return;

    _nomeForm.controller.text = apo.nome ?? '';
    _cpfForm.controller.text = formataCPF(apo.cpf ?? '');
    _dataNascimentoForm.controller.text = _dataBr(apo.dataNascimento);
    _telefoneForm.controller.text = formataCelular(apo.telefone ?? '');
    _whatsappForm.controller.text = formataCelular(apo.whatsapp ?? '');
    _cepForm.controller.text = _formataCep(apo.cep ?? '');
    _enderecoForm.controller.text = apo.endereco ?? '';
    _numeroForm.controller.text = apo.numero ?? '';
    _complementoForm.controller.text = apo.complemento ?? '';
    _bairroForm.controller.text = apo.bairro ?? '';
    _cidadeForm.controller.text = apo.cidade ?? '';
    _localVotacaoForm.controller.text = apo.localVotacao ?? '';
    _observacoesForm.controller.text = apo.observacoes ?? '';
    _intencaoVoto = apo.intencaoVoto ?? IntencaoVoto.indeciso;
    final cepDigits = (apo.cep ?? '').replaceAll(RegExp(r'\D'), '');
    if (cepDigits.length == 8) _ultimoCepBuscado = cepDigits;
  }

  String _formataCep(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return value;
    return '${digits.substring(0, 5)}-${digits.substring(5)}';
  }

  String _dataBr(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final parts = iso.split('T').first.split('-');
    if (parts.length != 3) return iso;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  String? _valorOpcional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _dataIso(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;
    return '${digits.substring(4, 8)}-${digits.substring(2, 4)}-${digits.substring(0, 2)}';
  }

  String _labelIntencao(String value) {
    switch (value) {
      case IntencaoVoto.confirmado:
        return 'Confirmado';
      case IntencaoVoto.apoiador:
        return 'Apoiador';
      case IntencaoVoto.simpatizante:
        return 'Simpatizante';
      case IntencaoVoto.indeciso:
      default:
        return 'Indeciso';
    }
  }

  void _selectIntencao(String value) {
    setState(() => _intencaoVoto = value);
  }

  Future<void> _onCepChanged(String value) async {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return;
    if (_buscandoCep || _ultimoCepBuscado == digits) return;

    setState(() => _buscandoCep = true);
    try {
      final endereco = await buscarEnderecoPorCep(digits);
      if (!mounted) return;

      if (endereco == null) {
        showToastWarning(message: 'CEP não encontrado');
        return;
      }

      _ultimoCepBuscado = digits;
      if (endereco.logradouro?.isNotEmpty == true) {
        _enderecoForm.controller.text = endereco.logradouro!;
      }
      if (endereco.bairro?.isNotEmpty == true) {
        _bairroForm.controller.text = endereco.bairro!;
      }
      if (endereco.cidade?.isNotEmpty == true) {
        _cidadeForm.controller.text = endereco.cidade!;
      }
      if (endereco.complemento?.isNotEmpty == true &&
          _complementoForm.value.trim().isEmpty) {
        _complementoForm.controller.text = endereco.complemento!;
      }
    } catch (_) {
      if (!mounted) return;
      showToastWarning(message: 'Não foi possível buscar o CEP');
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  bool _validarFormulario() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _salvarCadastro() {
    if (!_validarFormulario()) return;

    final apoiador = ApoiadorModel(
      id: widget.apoiador?.id,
      idLider: widget.apoiador?.idLider,
      nome: _nomeForm.value.trim(),
      cpf: _cpfForm.value,
      dataNascimento: _dataIso(_dataNascimentoForm.value),
      telefone: _valorOpcional(_telefoneForm.value),
      whatsapp: _valorOpcional(_whatsappForm.value),
      cep: _valorOpcional(_cepForm.value),
      endereco: _valorOpcional(_enderecoForm.value),
      numero: _valorOpcional(_numeroForm.value),
      complemento: _valorOpcional(_complementoForm.value),
      bairro: _valorOpcional(_bairroForm.value),
      cidade: _valorOpcional(_cidadeForm.value),
      localVotacao: _valorOpcional(_localVotacaoForm.value),
      intencaoVoto: _intencaoVoto,
      observacoes: _valorOpcional(_observacoesForm.value),
    );

    bloc.add(CadastroPessoaSaveEvent(apoiador: apoiador));
  }

  void _onStateChanged(CadastroPessoaState state) {
    if (state is CadastroPessoaSuccessState) {
      showToastSuccess(
        message: _isEdit
            ? 'Cadastro atualizado com sucesso'
            : 'Pessoa cadastrada com sucesso',
      );
      Navigator.of(context).pop(true);
      return;
    }
    if (state is CadastroPessoaErrorState) {
      showAppErrorSnackbar(state.errorModel);
    }
  }

  AppFormField _criarCampo({
    required String hint,
    required IconData icon,
    TextInputType? textInputType,
    TextInputFormatter? textInputFormatter,
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
      textInputFormatter: textInputFormatter,
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

  Widget _intencaoChip({
    required String value,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () => _selectIntencao(value),
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
          _labelIntencao(value),
          bold: selected,
          color: RamosColors.primaryDark,
          fontSize: AppFontSizes.verySmall,
        ),
      ),
    );
  }

  Widget _intencaoSection() {
    const opcoes = [
      IntencaoVoto.indeciso,
      IntencaoVoto.simpatizante,
      IntencaoVoto.apoiador,
      IntencaoVoto.confirmado,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Intenção de voto'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opcoes.map((opcao) {
            return _intencaoChip(
              value: opcao,
              selected: _intencaoVoto == opcao,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _dadosPessoais() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Dados pessoais'),
        _nomeForm.formulario,
        _cpfForm.formulario,
        _dataNascimentoForm.formulario,
        _telefoneForm.formulario,
        _whatsappForm.formulario,
      ],
    );
  }

  Widget _cepField() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        _cepForm.formulario,
        if (_buscandoCep)
          const Padding(
            padding: EdgeInsets.only(right: 16, top: 10),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: RamosColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _endereco() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Endereço',
          subtitle: 'Digite o CEP para preencher automaticamente',
        ),
        _cepField(),
        _enderecoForm.formulario,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _numeroForm.formulario),
            appSizedBox(width: 10),
            Expanded(flex: 2, child: _complementoForm.formulario),
          ],
        ),
        _bairroForm.formulario,
        _cidadeForm.formulario,
        _localVotacaoForm.formulario,
      ],
    );
  }

  Widget _observacoes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Observações'),
        _observacoesForm.formulario,
      ],
    );
  }

  Widget _formContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dadosPessoais(),
          _sectionDivider(),
          _endereco(),
          _sectionDivider(),
          _intencaoSection(),
          _sectionDivider(),
          _observacoes(),
          appSizedBox(height: 24),
          appElevatedButtonRamos(
            title: _isEdit ? 'Salvar alterações' : 'Salvar cadastro',
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
    return BlocConsumer<CadastroPessoaBloc, CadastroPessoaState>(
      bloc: bloc,
      listener: (context, state) => _onStateChanged(state),
      builder: (context, state) {
        if (state is CadastroPessoaLoadingState) {
          return appLoadingRamos();
        }
        return _body();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: _isEdit ? 'Editar pessoa' : 'Nova pessoa',
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
    for (final form in [
      _nomeForm,
      _cpfForm,
      _dataNascimentoForm,
      _telefoneForm,
      _whatsappForm,
      _cepForm,
      _enderecoForm,
      _numeroForm,
      _complementoForm,
      _bairroForm,
      _cidadeForm,
      _localVotacaoForm,
      _observacoesForm,
    ]) {
      form.controller.dispose();
    }
    bloc.close();
    super.dispose();
  }
}
