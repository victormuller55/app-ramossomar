import 'package:app_ramos_candidatura/app_config/app_enums.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:app_ramos_candidatura/app_config/const/app_endpoints.dart';
import 'package:app_ramos_candidatura/models/publicacao_model.dart';
import 'package:app_ramos_candidatura/pages/feed/cadastro_publicacao/cadastro_publicacao_page.dart';
import 'package:app_ramos_candidatura/pages/feed/feed_bloc.dart';
import 'package:app_ramos_candidatura/pages/feed/feed_event.dart';
import 'package:app_ramos_candidatura/pages/feed/feed_state.dart';
import 'package:app_ramos_candidatura/widgets/app_loading.dart';
import 'package:app_ramos_candidatura/widgets/empty.dart';
import 'package:app_ramos_candidatura/widgets/ramos_add_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

class FeedPage extends StatefulWidget {
  final bool showAddFab;

  const FeedPage({super.key, this.showAddFab = false});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  final FeedBloc bloc = FeedBloc();
  final List<PublicacaoModel> _publicacoes = <PublicacaoModel>[];
  final Set<String> _expandedIds = <String>{};

  static const int _conteudoLimite = 160;

  @override
  void initState() {
    super.initState();
    bloc.add(FeedLoadEvent());
  }

  Future<void> _refresh() async {
    bloc.add(FeedLoadEvent(forceRefresh: true));
    await bloc.stream.firstWhere((s) => s is! FeedLoadingState);
  }

  Future<void> _abrirCadastro() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CadastroPublicacaoPage()));
    if (result == true && mounted) {
      bloc.add(FeedLoadEvent(forceRefresh: true));
    }
  }

  void _aplicarSucesso(FeedSuccessState state) {
    _publicacoes
      ..clear()
      ..addAll(state.publicacoes);
  }

  void _onStateChanged(FeedState state) {
    if (state is FeedSuccessState) {
      _aplicarSucesso(state);
    }
  }

  String _formatarData(String? value) {
    if (value == null || value.isEmpty) return '';
    final raw = value.split('.').first.replaceFirst('T', ' ');
    final parts = raw.split(' ');
    if (parts.isEmpty) return value;

    final date = parts[0].split('-');
    if (date.length != 3) return raw;

    final hora = parts.length > 1 && parts[1].length >= 5 ? parts[1].substring(0, 5) : '';
    final data = '${date[2]}/${date[1]}/${date[0]}';
    return hora.isEmpty ? data : '$data · $hora';
  }

  String _resumo(String? conteudo) {
    final text = (conteudo ?? '').trim();
    if (text.length <= _conteudoLimite) return text;
    return '${text.substring(0, _conteudoLimite).trimRight()}...';
  }

  bool _conteudoLongo(String? conteudo) {
    return (conteudo ?? '').trim().length > _conteudoLimite;
  }

  bool _isExpanded(PublicacaoModel pub) {
    return pub.id != null && _expandedIds.contains(pub.id);
  }

  void _toggleLerMais(PublicacaoModel pub) {
    final id = pub.id;
    if (id == null || id.isEmpty) return;
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  Widget _authorAvatar(PublicacaoModel pub) {
    return appContainer(
      width: 44,
      height: 44,
      radius: BorderRadius.circular(360),
      gradient: LinearGradient(
        colors: [RamosColors.primary.withValues(alpha: 0.9), RamosColors.primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Center(
        child: appText(
          pub.iniciaisAutor,
          bold: true,
          color: AppColors.white,
          fontSize: AppFontSizes.verySmall,
        ),
      ),
    );
  }

  Widget _midiaBadge(PublicacaoModel pub) {
    final isVideo = pub.isVideo || pub.tipoMidia == TipoMidia.video;
    return appContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      backgroundColor: AppColors.white.withValues(alpha: 0.92),
      radius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVideo ? Icons.play_circle_outline_rounded : Icons.image_outlined,
            size: 14,
            color: RamosColors.primaryDark,
          ),
          appSizedBox(width: 4),
          appText(
            isVideo ? 'Vídeo' : 'Imagem',
            bold: true,
            color: RamosColors.primaryDark,
            fontSize: 11,
          ),
        ],
      ),
    );
  }

  Widget _midiaFallback(bool isVideo) {
    return appContainer(
      width: double.infinity,
      backgroundColor: RamosColors.primaryDark,
      gradient: LinearGradient(
        colors: [
          RamosColors.primaryDark,
          RamosColors.primary,
          RamosColors.secondary.withValues(alpha: 0.55),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Center(
        child: Icon(
          isVideo ? Icons.videocam_rounded : Icons.campaign_rounded,
          color: AppColors.white.withValues(alpha: 0.9),
          size: 42,
        ),
      ),
    );
  }

  Widget _midiaPreview(PublicacaoModel pub) {
    final url = fotoUrl(pub.midia);
    final isVideo = pub.isVideo || pub.tipoMidia == TipoMidia.video;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: url.isNotEmpty && !isVideo
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => _midiaFallback(isVideo),
                  )
                : _midiaFallback(isVideo),
          ),
          Positioned(top: 12, left: 12, child: _midiaBadge(pub)),
          if (isVideo)
            Positioned.fill(
              child: Center(
                child: appContainer(
                  width: 56,
                  height: 56,
                  backgroundColor: AppColors.black.withValues(alpha: 0.45),
                  radius: BorderRadius.circular(360),
                  child: Icon(Icons.play_arrow_rounded, color: AppColors.white, size: 34),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _postHeader(PublicacaoModel pub) {
    return Row(
      children: [
        _authorAvatar(pub),
        appSizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              appText(
                pub.nomeAutor?.isNotEmpty == true ? pub.nomeAutor! : 'Campanha',
                bold: true,
                color: RamosColors.primaryDark,
                fontSize: AppFontSizes.verySmall,
                maxLines: 1,
                overflow: true,
              ),
              appSizedBox(height: 2),
              appText(_formatarData(pub.dataCriacao), color: AppColors.grey600, fontSize: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _postConteudo(PublicacaoModel pub) {
    final expandido = _isExpanded(pub);
    final longo = _conteudoLongo(pub.conteudo);
    final texto = expandido ? (pub.conteudo ?? '').trim() : _resumo(pub.conteudo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        appText(
          pub.titulo ?? 'Sem título',
          bold: true,
          color: AppColors.grey900,
          fontSize: AppFontSizes.small,
        ),
        appSizedBox(height: 6),
        appText(texto, color: AppColors.grey600, fontSize: AppFontSizes.verySmall),
        if (longo) ...[
          appSizedBox(height: 6),
          GestureDetector(
            onTap: () => _toggleLerMais(pub),
            child: appText(
              expandido ? 'Ler menos' : 'Ler mais',
              bold: true,
              color: RamosColors.primary,
              fontSize: AppFontSizes.verySmall,
            ),
          ),
        ],
      ],
    );
  }

  Widget _postCard(PublicacaoModel pub) {
    return appContainer(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      backgroundColor: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _postHeader(pub),
          appSizedBox(height: 12),
          _postConteudo(pub),
          if (pub.temMidia) ...[appSizedBox(height: 12), _midiaPreview(pub)],
        ],
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
      children: [
        emptyMessage(
          title: 'Nenhuma publicação ainda',
          subtitle: widget.showAddFab
              ? 'Toque no + para criar a primeira publicação.'
              : 'Quando houver novidades da campanha, elas aparecerão aqui.',
          icon: Icons.dynamic_feed_rounded,
        ),
      ],
    );
  }

  Widget _list() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 5, bottom: 120),
      itemCount: _publicacoes.length,
      itemBuilder: (context, index) => _postCard(_publicacoes[index]),
    );
  }

  Widget _body() {
    return RefreshIndicator(
      color: RamosColors.primary,
      onRefresh: _refresh,
      child: _publicacoes.isEmpty ? _emptyState() : _list(),
    );
  }

  Widget _bodyBuilder() {
    return BlocConsumer<FeedBloc, FeedState>(
      bloc: bloc,
      listener: (context, state) => _onStateChanged(state),
      builder: (context, state) {
        if (state is FeedLoadingState || state is FeedInitialState) {
          return appLoadingRamos();
        }
        if (state is FeedErrorState) {
          return appError(
            state.errorModel,
            function: () => bloc.add(FeedLoadEvent(forceRefresh: true)),
          );
        }
        return _body();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Feed',
      background: const Color(0xFFE8EBE6),
      appBarColor: RamosColors.primaryDark,
      titleColor: AppColors.white,
      drawerColor: AppColors.white,
      hideBackIcon: true,
      centerTitle: true,
      floatingActionButton: widget.showAddFab ? ramosAddFab(onTap: _abrirCadastro) : null,
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}
