import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/function/service/session_expired.dart';
import 'package:app_ramos_candidatura/function/share_file.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:app_ramos_candidatura/models/cidade_model.dart';
import 'package:app_ramos_candidatura/models/local_votacao_model.dart';
import 'package:app_ramos_candidatura/pages/admin/relatorios/relatorios_bloc.dart';
import 'package:app_ramos_candidatura/pages/admin/relatorios/relatorios_event.dart';
import 'package:app_ramos_candidatura/pages/admin/relatorios/relatorios_state.dart';
import 'package:app_ramos_candidatura/services/cidade_service.dart';
import 'package:app_ramos_candidatura/services/local_votacao_service.dart';
import 'package:app_ramos_candidatura/widgets/app_elevated_button.dart';
import 'package:app_ramos_candidatura/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  final RelatoriosBloc bloc = RelatoriosBloc();

  List<CidadeModel> _cidades = [];
  List<LocalVotacaoModel> _locaisVotacao = [];
  CidadeModel? _cidadeSelecionada;
  LocalVotacaoModel? _localSelecionado;
  String? _intencaoVoto;

  bool _carregandoCidades = false;

  bool get _temFiltros {
    return _cidadeSelecionada != null ||
        _localSelecionado != null ||
        _intencaoVoto != null;
  }

  @override
  void initState() {
    super.initState();
    _carregarCidades();
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
        .replaceAll(RegExp(r'[ç]'), 'c');
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregandoCidades = false);
      if (await tratarSessaoExpirada(e)) return;
      showToastWarning(message: 'Não foi possível carregar as cidades');
    }
  }

  Future<List<LocalVotacaoModel>> _buscarLocais(String idCidade) async {
    return listarLocaisVotacao(idCidade: idCidade, ativo: true);
  }

  void _exportar(String formato) {
    bloc.add(
      RelatoriosExportEvent(
        formato: formato,
        cidade: _cidadeSelecionada?.nome,
        localVotacao: _localSelecionado?.nome,
        intencaoVoto: _intencaoVoto,
      ),
    );
  }

  Future<void> _onSuccess(RelatoriosSuccessState state) async {
    if (!mounted) return;

    final label = state.formato.toUpperCase();
    final fileName = state.filePath.split(RegExp(r'[\\/]')).last;
    showToastSuccess(message: 'Relatório $label gerado');

    try {
      await shareAppFile(
        context,
        filePath: state.filePath,
        fileName: fileName,
        subject: 'Relatório de cadastrados ($label)',
      );
    } catch (e) {
      if (!mounted) return;
      showToastError(message: 'Não foi possível compartilhar o arquivo');
    }
  }

  void _onStateChanged(RelatoriosState state) {
    if (state is RelatoriosSuccessState) {
      _onSuccess(state);
    }
    if (state is RelatoriosErrorState) {
      showAppErrorSnackbar(state.errorModel);
    }
  }

  String _labelIntencao(String? value) {
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
        return 'Todas';
    }
  }

  void _limparFiltros() {
    setState(() {
      _cidadeSelecionada = null;
      _localSelecionado = null;
      _locaisVotacao = [];
      _intencaoVoto = null;
    });
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
                        keyboardType: TextInputType.text,
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
                                final isSelected =
                                    selecionado != null && equals(item, selecionado);
                                return ListTile(
                                  title: appText(
                                    labelOf(item),
                                    bold: isSelected,
                                    color: RamosColors.primaryDark,
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_rounded, color: RamosColors.primary)
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

  Widget _dropdownCampo({
    required String hint,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    if (loading) {
      return appContainer(
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
      );
    }

    return GestureDetector(
      onTap: onTap,
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
                value?.isNotEmpty == true ? value! : hint,
                color: value?.isNotEmpty == true ? AppColors.grey900 : AppColors.grey600,
                fontSize: AppFontSizes.verySmall,
                maxLines: 1,
                overflow: true,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey600),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirFiltros() async {
    var cidadeDraft = _cidadeSelecionada;
    var localDraft = _localSelecionado;
    var locaisDraft = List<LocalVotacaoModel>.from(_locaisVotacao);
    var intencaoDraft = _intencaoVoto;
    var carregandoLocaisDraft = false;

    final aplicado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> selecionarCidade() async {
                if (_carregandoCidades) return;
                if (_cidades.isEmpty) {
                  showToastWarning(message: 'Nenhuma cidade disponível');
                  return;
                }

                final selecionada = await _abrirSeletor<CidadeModel>(
                  titulo: 'Selecionar cidade',
                  itens: _cidades,
                  labelOf: (c) => c.label,
                  selecionado: cidadeDraft,
                  equals: (a, b) => a.id == b.id,
                );
                if (selecionada == null) return;
                if (selecionada.id == cidadeDraft?.id) return;

                setModalState(() {
                  cidadeDraft = selecionada;
                  localDraft = null;
                  locaisDraft = [];
                  carregandoLocaisDraft = true;
                });

                try {
                  final locais = await _buscarLocais(selecionada.id!);
                  if (!mounted) return;
                  setModalState(() {
                    locaisDraft = locais;
                    carregandoLocaisDraft = false;
                  });
                } catch (e) {
                  if (!mounted) return;
                  setModalState(() => carregandoLocaisDraft = false);
                  if (await tratarSessaoExpirada(e)) return;
                  showToastWarning(message: 'Não foi possível carregar os locais de votação');
                }
              }

              Future<void> selecionarLocal() async {
                if (cidadeDraft == null) {
                  showToastWarning(message: 'Selecione a cidade primeiro');
                  return;
                }
                if (carregandoLocaisDraft) return;
                if (locaisDraft.isEmpty) {
                  showToastWarning(message: 'Nenhum local de votação para esta cidade');
                  return;
                }

                final selecionado = await _abrirSeletor<LocalVotacaoModel>(
                  titulo: 'Local de votação',
                  itens: locaisDraft,
                  labelOf: (l) => l.label,
                  selecionado: localDraft,
                  equals: (a, b) => a.id == b.id,
                );
                if (selecionado == null) return;
                setModalState(() => localDraft = selecionado);
              }

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: appContainer(
                          width: 40,
                          height: 4,
                          backgroundColor: AppColors.grey200,
                          radius: BorderRadius.circular(20),
                        ),
                      ),
                      appSizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: appText(
                              'Filtros',
                              bold: true,
                              color: RamosColors.primaryDark,
                              fontSize: AppFontSizes.small,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            icon: Icon(Icons.close_rounded, color: AppColors.grey600),
                          ),
                        ],
                      ),
                      appText(
                        'Opcionais — deixe em branco para exportar todos',
                        color: AppColors.grey600,
                        fontSize: 12,
                      ),
                      appSizedBox(height: 16),
                      _dropdownCampo(
                        hint: _carregandoCidades
                            ? 'Carregando cidades...'
                            : 'Filtrar por cidade (opcional)',
                        value: cidadeDraft?.label,
                        icon: Icons.location_city_rounded,
                        loading: _carregandoCidades,
                        onTap: selecionarCidade,
                      ),
                      appSizedBox(height: 12),
                      _dropdownCampo(
                        hint: cidadeDraft == null
                            ? 'Selecione a cidade primeiro'
                            : 'Filtrar por local de votação (opcional)',
                        value: localDraft?.label,
                        icon: Icons.how_to_vote_rounded,
                        loading: carregandoLocaisDraft,
                        onTap: selecionarLocal,
                      ),
                      appSizedBox(height: 16),
                      appText(
                        'Intenção de voto: ${_labelIntencao(intencaoDraft)}',
                        color: AppColors.grey600,
                        fontSize: 12,
                      ),
                      appSizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          null,
                          IntencaoVoto.indeciso,
                          IntencaoVoto.simpatizante,
                          IntencaoVoto.apoiador,
                          IntencaoVoto.confirmado,
                        ].map((opcao) {
                          final selected = intencaoDraft == opcao;
                          return GestureDetector(
                            onTap: () => setModalState(() => intencaoDraft = opcao),
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
                                _labelIntencao(opcao),
                                bold: selected,
                                color: RamosColors.primaryDark,
                                fontSize: AppFontSizes.verySmall,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      appSizedBox(height: 24),
                      appElevatedButtonRamos(
                        title: 'Aplicar filtros',
                        onTap: () => Navigator.of(context).pop(true),
                      ),
                      appSizedBox(height: 10),
                      appElevatedButtonRamos(
                        title: 'Limpar',
                        primary: false,
                        onTap: () {
                          setModalState(() {
                            cidadeDraft = null;
                            localDraft = null;
                            locaisDraft = [];
                            intencaoDraft = null;
                            carregandoLocaisDraft = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (aplicado == true && mounted) {
      setState(() {
        _cidadeSelecionada = cidadeDraft;
        _localSelecionado = localDraft;
        _locaisVotacao = locaisDraft;
        _intencaoVoto = intencaoDraft;
      });
    }
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

  Widget _introCard() {
    return appContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.white,
      radius: BorderRadius.circular(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appContainer(
            width: 48,
            height: 48,
            backgroundColor: RamosColors.primary.withValues(alpha: 0.12),
            radius: BorderRadius.circular(14),
            child: const Icon(Icons.file_download_outlined, color: RamosColors.primary),
          ),
          appSizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appText(
                  'Cadastrados',
                  bold: true,
                  color: RamosColors.primaryDark,
                  fontSize: AppFontSizes.small,
                ),
                appSizedBox(height: 4),
                appText(
                  'Exporte a lista completa em planilha (XLSX) ou documento (PDF).',
                  color: AppColors.grey600,
                  fontSize: 13,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumoFiltros() {
    final chips = <String>[
      if (_cidadeSelecionada != null) 'Cidade: ${_cidadeSelecionada!.label}',
      if (_localSelecionado != null) 'Local: ${_localSelecionado!.label}',
      if (_intencaoVoto != null) 'Intenção: ${_labelIntencao(_intencaoVoto)}',
    ];

    return GestureDetector(
      onTap: _abrirFiltros,
      child: appContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        backgroundColor: AppColors.white,
        radius: BorderRadius.circular(16),
        border: Border.all(
          color: _temFiltros ? RamosColors.primary : AppColors.grey200,
        ),
        child: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              color: RamosColors.primaryDark,
              size: 22,
            ),
            appSizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appText(
                    'Filtros',
                    bold: true,
                    color: RamosColors.primaryDark,
                    fontSize: AppFontSizes.verySmall,
                  ),
                  appSizedBox(height: 2),
                  appText(
                    chips.isEmpty ? 'Nenhum filtro aplicado' : chips.join(' · '),
                    color: AppColors.grey600,
                    fontSize: 12,
                    maxLines: 2,
                    overflow: true,
                  ),
                ],
              ),
            ),
            if (_temFiltros)
              GestureDetector(
                onTap: _limparFiltros,
                child: Icon(Icons.close_rounded, color: AppColors.grey600, size: 20),
              )
            else
              Icon(Icons.chevron_right_rounded, color: AppColors.grey600),
          ],
        ),
      ),
    );
  }

  Widget _botoesExport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Exportar'),
        appElevatedButtonRamos(title: 'Exportar XLSX', onTap: () => _exportar('xlsx')),
        appSizedBox(height: 12),
        appElevatedButtonRamos(
          title: 'Exportar PDF',
          primary: false,
          onTap: () => _exportar('pdf'),
        ),
      ],
    );
  }

  Widget _body() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      children: [
        _introCard(),
        appSizedBox(height: 16),
        _resumoFiltros(),
        appSizedBox(height: 28),
        _botoesExport(),
      ],
    );
  }

  Widget _bodyBuilder() {
    return BlocConsumer<RelatoriosBloc, RelatoriosState>(
      bloc: bloc,
      listener: (context, state) => _onStateChanged(state),
      builder: (context, state) {
        if (state is RelatoriosLoadingState) {
          return appLoadingRamos();
        }
        return _body();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Relatórios',
      background: AppColors.grey50,
      appBarColor: RamosColors.primaryDark,
      titleColor: AppColors.white,
      drawerColor: AppColors.white,
      hideBackIcon: true,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _abrirFiltros,
          icon: Badge(
            isLabelVisible: _temFiltros,
            smallSize: 8,
            child: Icon(Icons.tune_rounded, color: AppColors.white),
          ),
        ),
      ],
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}
