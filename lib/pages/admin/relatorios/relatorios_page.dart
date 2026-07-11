import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/function/share_file.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:app_ramos_candidatura/pages/admin/relatorios/relatorios_bloc.dart';
import 'package:app_ramos_candidatura/pages/admin/relatorios/relatorios_event.dart';
import 'package:app_ramos_candidatura/pages/admin/relatorios/relatorios_state.dart';
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
  late final AppFormField _cidadeForm;
  String? _intencaoVoto;

  @override
  void initState() {
    super.initState();
    _criarCampoCidade();
  }

  void _criarCampoCidade() {
    _cidadeForm = AppFormField(
      context: context,
      hint: 'Filtrar por cidade (opcional)',
      icon: const Icon(Icons.location_city_rounded),
      iconColor: RamosColors.primary,
      inputColor: AppColors.grey900,
      hintColor: AppColors.grey600,
      backgroundColor: AppColors.white,
      borderColor: AppColors.grey200,
      hoverBorderColor: RamosColors.primary,
      radius: 14,
    );
  }

  String? _valorOpcional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _exportar(String formato) {
    bloc.add(
      RelatoriosExportEvent(
        formato: formato,
        cidade: _valorOpcional(_cidadeForm.value),
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

  Widget _filtroChip({required String? value, required String label, required bool selected}) {
    return GestureDetector(
      onTap: () => setState(() => _intencaoVoto = value),
      child: appContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        backgroundColor: selected ? RamosColors.secondary.withValues(alpha: 0.35) : AppColors.white,
        radius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? RamosColors.primary : AppColors.grey200,
          width: selected ? 1.5 : 1,
        ),
        child: appText(
          label,
          bold: selected,
          color: RamosColors.primaryDark,
          fontSize: AppFontSizes.verySmall,
        ),
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

  Widget _filtros() {
    const opcoes = <String?>[
      null,
      IntencaoVoto.indeciso,
      IntencaoVoto.simpatizante,
      IntencaoVoto.apoiador,
      IntencaoVoto.confirmado,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Filtros', subtitle: 'Opcionais — deixe em branco para exportar todos'),
        _cidadeForm.formulario,
        appSizedBox(height: 8),
        appText(
          'Intenção de voto: ${_labelIntencao(_intencaoVoto)}',
          color: AppColors.grey600,
          fontSize: 12,
        ),
        appSizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opcoes.map((opcao) {
            return _filtroChip(
              value: opcao,
              label: _labelIntencao(opcao),
              selected: _intencaoVoto == opcao,
            );
          }).toList(),
        ),
      ],
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
        appSizedBox(height: 24),
        _filtros(),
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
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    _cidadeForm.controller.dispose();
    bloc.close();
    super.dispose();
  }
}
