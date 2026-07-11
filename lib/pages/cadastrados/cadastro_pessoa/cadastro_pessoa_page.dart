import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;
import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/function/form_validation.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:app_ramos_candidatura/function/validators.dart';
import 'package:app_ramos_candidatura/function/via_cep.dart';
import 'package:app_ramos_candidatura/models/apoiador_model.dart';
import 'package:app_ramos_candidatura/models/cidade_model.dart';
import 'package:app_ramos_candidatura/models/local_votacao_model.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastro_pessoa/cadastro_pessoa_bloc.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastro_pessoa/cadastro_pessoa_event.dart';
import 'package:app_ramos_candidatura/pages/cadastrados/cadastro_pessoa/cadastro_pessoa_state.dart';
import 'package:app_ramos_candidatura/services/cidade_service.dart';
import 'package:app_ramos_candidatura/services/local_votacao_service.dart';
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

  List<CidadeModel> _cidades = [];
  List<LocalVotacaoModel> _locaisVotacao = [];
  CidadeModel? _cidadeSelecionada;
  LocalVotacaoModel? _localSelecionado;
  bool _carregandoCidades = false;
  bool _carregandoLocais = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.apoiador?.id != null && widget.apoiador!.id!.isNotEmpty;
    _criarCampos();
    _preencherFormulario();
    _carregarCidades();
  }

  void _criarCampos() {
    _nomeForm = _criarCampo(
      hint: 'Nome completo',
      icon: Icons.person_rounded,
      validator: validateNome,
    );
    _cpfForm = _criarCampo(
      hint: 'CPF',
      icon: Icons.badge_rounded,
      textInputType: TextInputType.number,
      textInputFormatter: AppFormFormatters.cpf,
      validator: validateCpf,
    );
    _dataNascimentoForm = _criarCampo(
      hint: 'Data de nascimento',
      icon: Icons.calendar_today_rounded,
      textInputType: TextInputType.number,
      textInputFormatter: AppFormFormatters.data,
      validator: validateDataNascimento,
    );
    _telefoneForm = _criarCampo(
      hint: 'Telefone',
      icon: Icons.phone_rounded,
      textInputType: TextInputType.phone,
      textInputFormatter: AppFormFormatters.telefone,
    );
    _whatsappForm = _criarCampo(
      hint: 'WhatsApp',
      icon: Icons.chat_rounded,
      textInputType: TextInputType.phone,
      textInputFormatter: AppFormFormatters.telefone,
    );
    _cepForm = _criarCampo(
      hint: 'CEP',
      icon: Icons.markunread_mailbox_rounded,
      textInputType: TextInputType.number,
      textInputFormatter: AppFormFormatters.cep,
      onChange: _onCepChanged,
    );
    _enderecoForm = _criarCampo(
      hint: 'Endereço',
      icon: Icons.home_rounded,
    );
    _numeroForm = _criarCampo(
      hint: 'Número',
      icon: Icons.tag_rounded,
      textInputType: TextInputType.number,
    );
    _complementoForm = _criarCampo(
      hint: 'Complemento',
      icon: Icons.apartment_rounded,
    );
    _bairroForm = _criarCampo(
      hint: 'Bairro',
      icon: Icons.location_city_rounded,
    );
    _cidadeForm = _criarCampo(
      hint: 'Cidade',
      icon: Icons.location_on_rounded,
      showKeyboard: false,
      onTap: _abrirSeletorCidade,
      suffixIcon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.grey600,
      ),
    );
    _localVotacaoForm = _criarCampo(
      hint: 'Local de votação',
      icon: Icons.how_to_vote_rounded,
      showKeyboard: false,
      onTap: _abrirSeletorLocal,
      suffixIcon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.grey600,
      ),
    );
    _observacoesForm = _criarCampo(
      hint: 'Observações',
      icon: Icons.notes_rounded,
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

  String? _valorOpcional(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _dataIso(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;
    return '${digits.substring(4, 8)}-${digits.substring(2, 4)}-${digits.substring(0, 2)}';
  }

  String _normalizar(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c');
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

  Future<void> _carregarCidades() async {
    setState(() => _carregandoCidades = true);
    try {
      final cidades = await listarCidades();
      if (!mounted) return;
      setState(() {
        _cidades = cidades;
        _carregandoCidades = false;
      });

      final nomeCidade = widget.apoiador?.cidade;
      if (nomeCidade != null && nomeCidade.isNotEmpty) {
        await _selecionarCidadePorNome(
          nomeCidade,
          nomeLocal: widget.apoiador?.localVotacao,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregandoCidades = false);
      if (await tratarSessaoExpirada(e)) return;
      showToastWarning(message: 'Não foi possível carregar as cidades');
    }
  }

  Future<void> _carregarLocais({String? nomeLocalParaSelecionar}) async {
    final idCidade = _cidadeSelecionada?.id;
    if (idCidade == null || idCidade.isEmpty) {
      setState(() {
        _locaisVotacao = [];
        _localSelecionado = null;
        _carregandoLocais = false;
        _localVotacaoForm.controller.clear();
      });
      return;
    }

    setState(() {
      _carregandoLocais = true;
      _localSelecionado = null;
      _locaisVotacao = [];
      _localVotacaoForm.controller.clear();
    });

    try {
      final locais = await listarLocaisVotacao(idCidade: idCidade, ativo: true);
      if (!mounted) return;

      LocalVotacaoModel? selecionado;
      if (nomeLocalParaSelecionar != null && nomeLocalParaSelecionar.isNotEmpty) {
        selecionado = _encontrarLocal(locais, nomeLocalParaSelecionar);
      }

      setState(() {
        _locaisVotacao = locais;
        _localSelecionado = selecionado;
        _carregandoLocais = false;
        _localVotacaoForm.controller.text = selecionado?.nome ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregandoLocais = false);
      if (await tratarSessaoExpirada(e)) return;
      showToastWarning(message: 'Não foi possível carregar os locais de votação');
    }
  }

  CidadeModel? _encontrarCidade(String nome, {String? uf}) {
    final n = _normalizar(nome);
    final u = uf?.trim().toUpperCase();

    for (final cidade in _cidades) {
      if (u != null && u.isNotEmpty && (cidade.uf ?? '').toUpperCase() != u) {
        continue;
      }
      if (_normalizar(cidade.nome ?? '') == n) return cidade;
    }

    for (final cidade in _cidades) {
      if (u != null && u.isNotEmpty && (cidade.uf ?? '').toUpperCase() != u) {
        continue;
      }
      final nomeCidade = _normalizar(cidade.nome ?? '');
      if (nomeCidade.contains(n) || n.contains(nomeCidade)) return cidade;
    }
    return null;
  }

  LocalVotacaoModel? _encontrarLocal(List<LocalVotacaoModel> locais, String nome) {
    final n = _normalizar(nome);
    for (final local in locais) {
      if (_normalizar(local.nome ?? '') == n) return local;
    }
    for (final local in locais) {
      final nomeLocal = _normalizar(local.nome ?? '');
      if (nomeLocal.contains(n) || n.contains(nomeLocal)) return local;
    }
    return null;
  }

  Future<void> _selecionarCidadePorNome(
    String nome, {
    String? uf,
    String? nomeLocal,
  }) async {
    final cidade = _encontrarCidade(nome, uf: uf);
    if (cidade == null) return;
    await _onCidadeSelected(cidade, nomeLocalParaSelecionar: nomeLocal);
  }

  Future<void> _onCidadeSelected(
    CidadeModel cidade, {
    String? nomeLocalParaSelecionar,
  }) async {
    setState(() {
      _cidadeSelecionada = cidade;
      _localSelecionado = null;
      _locaisVotacao = [];
      _cidadeForm.controller.text = cidade.nome ?? '';
      _localVotacaoForm.controller.clear();
    });
    await _carregarLocais(nomeLocalParaSelecionar: nomeLocalParaSelecionar);
  }

  void _onLocalSelected(LocalVotacaoModel local) {
    setState(() {
      _localSelecionado = local;
      _localVotacaoForm.controller.text = local.nome ?? '';
    });
  }

  Future<void> _abrirSeletorCidade() async {
    if (_carregandoCidades) return;
    if (_cidades.isEmpty) {
      showToastWarning(message: 'Nenhuma cidade disponível');
      return;
    }

    final selecionada = await _abrirSeletor<CidadeModel>(
      titulo: 'Selecionar cidade',
      itens: _cidades,
      labelOf: (c) => c.label,
      selecionado: _cidadeSelecionada,
      equals: (a, b) => a.id == b.id,
    );
    if (selecionada == null) return;
    if (selecionada.id == _cidadeSelecionada?.id) return;
    await _onCidadeSelected(selecionada);
  }

  Future<void> _abrirSeletorLocal() async {
    if (_cidadeSelecionada == null) {
      showToastWarning(message: 'Selecione a cidade primeiro');
      return;
    }
    if (_carregandoLocais) return;
    if (_locaisVotacao.isEmpty) {
      showToastWarning(message: 'Nenhum local de votação para esta cidade');
      return;
    }

    final selecionado = await _abrirSeletor<LocalVotacaoModel>(
      titulo: 'Local de votação',
      itens: _locaisVotacao,
      labelOf: (l) => l.label,
      selecionado: _localSelecionado,
      equals: (a, b) => a.id == b.id,
    );
    if (selecionado == null) return;
    _onLocalSelected(selecionado);
  }

  Future<T?> _abrirSeletor<T>({
    required String titulo,
    required List<T> itens,
    required String Function(T) labelOf,
    required T? selecionado,
    required bool Function(T, T) equals,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String busca = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtrados = itens.where((item) {
              if (busca.trim().isEmpty) return true;
              return _normalizar(labelOf(item)).contains(_normalizar(busca));
            }).toList();

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: appText(
                              titulo,
                              bold: true,
                              color: RamosColors.primaryDark,
                              fontSize: AppFontSizes.small,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.close_rounded, color: AppColors.grey600),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: (value) => setModalState(() => busca = value),
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          prefixIcon: Icon(Icons.search_rounded, color: RamosColors.primary),
                          filled: true,
                          fillColor: AppColors.grey50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: RamosColors.primary),
                          ),
                        ),
                      ),
                    ),
                    appSizedBox(height: 8),
                    Expanded(
                      child: filtrados.isEmpty
                          ? Center(
                              child: appText(
                                'Nenhum item encontrado',
                                color: AppColors.grey600,
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtrados.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: AppColors.grey200,
                              ),
                              itemBuilder: (context, index) {
                                final item = filtrados[index];
                                final isSelected = selecionado != null &&
                                    equals(item, selecionado);
                                return ListTile(
                                  title: appText(
                                    labelOf(item),
                                    bold: isSelected,
                                    color: RamosColors.primaryDark,
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: RamosColors.primary,
                                        )
                                      : null,
                                  onTap: () => Navigator.of(context).pop(item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        await _selecionarCidadePorNome(
          endereco.cidade!,
          uf: endereco.uf,
        );
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
    return validarFormularioComFeedback(_formKey);
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
      cidade: _valorOpcional(_cidadeSelecionada?.nome),
      localVotacao: _valorOpcional(_localSelecionado?.nome),
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
    Widget? suffixIcon,
    VoidCallback? onTap,
    bool showKeyboard = true,
  }) {
    return AppFormField(
      context: context,
      hint: hint,
      icon: Icon(icon, size: 22),
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
      suffixIcon: suffixIcon,
      onTap: onTap,
      showKeyboard: showKeyboard,
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
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10),
            child: appLoadingRamos(size: 18),
          ),
      ],
    );
  }

  Widget _selectField({
    required AppFormField form,
    required String hint,
    required IconData icon,
    bool loading = false,
  }) {
    if (!loading) return form.formulario;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: appContainer(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        backgroundColor: AppColors.white,
        radius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
        child: Row(
          children: [
            Icon(icon, size: 22, color: RamosColors.primary),
            appSizedBox(width: 12),
            Expanded(
              child: appText(
                hint,
                color: AppColors.grey600,
                fontSize: AppFontSizes.verySmall,
              ),
            ),
            appLoadingRamos(size: 18),
          ],
        ),
      ),
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
        _numeroForm.formulario,
        _complementoForm.formulario,
        _bairroForm.formulario,
        _selectField(
          form: _cidadeForm,
          hint: 'Carregando cidades...',
          icon: Icons.location_on_rounded,
          loading: _carregandoCidades,
        ),
        _selectField(
          form: _localVotacaoForm,
          hint: 'Carregando locais...',
          icon: Icons.how_to_vote_rounded,
          loading: _carregandoLocais,
        ),
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
