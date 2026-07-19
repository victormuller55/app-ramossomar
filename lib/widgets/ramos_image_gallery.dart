import 'package:app_ramos_candidatura/widgets/ramos_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

/// Abre as imagens em tela cheia, com swipe horizontal quando houver mais de uma.
Future<void> openRamosImageGallery(
  BuildContext context, {
  required List<String> urls,
  List<String>? heroTags,
  int initialIndex = 0,
}) async {
  if (urls.isEmpty) return;

  final index = initialIndex.clamp(0, urls.length - 1);
  await Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return RamosImageGalleryPage(
          urls: urls,
          heroTags: heroTags,
          initialIndex: index,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class RamosImageGalleryPage extends StatefulWidget {
  final List<String> urls;
  final List<String>? heroTags;
  final int initialIndex;

  const RamosImageGalleryPage({
    super.key,
    required this.urls,
    this.heroTags,
    this.initialIndex = 0,
  });

  @override
  State<RamosImageGalleryPage> createState() => _RamosImageGalleryPageState();
}

class _RamosImageGalleryPageState extends State<RamosImageGalleryPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  String? _heroTag(int index) {
    final tags = widget.heroTags;
    if (tags == null || index < 0 || index >= tags.length) return null;
    final tag = tags[index];
    return tag.isEmpty ? null : tag;
  }

  Widget _imagem(String url, int index) {
    Widget image = RotatedBox(
      quarterTurns: 1,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.broken_image_outlined,
            color: AppColors.white.withValues(alpha: 0.7),
            size: 48,
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const RamosShimmer(width: 120, height: 120);
        },
      ),
    );

    final tag = _heroTag(index);
    if (tag != null) {
      image = Hero(
        tag: tag,
        child: Material(
          color: Colors.transparent,
          child: image,
        ),
      );
    }

    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: image,
        ),
      ),
    );
  }

  Widget _contador() {
    if (widget.urls.length <= 1) return const SizedBox.shrink();

    return appContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      backgroundColor: AppColors.black.withValues(alpha: 0.45),
      radius: BorderRadius.circular(20),
      child: appText(
        '${_currentIndex + 1}/${widget.urls.length}',
        bold: true,
        color: AppColors.white,
        fontSize: 12,
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.urls.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _imagem(widget.urls[index], index),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: _contador(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
