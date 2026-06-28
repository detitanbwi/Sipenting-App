import 'dart:io';
import 'package:flutter/material.dart';
import '../services/offline_article_service.dart';
import '../theme/colors.dart';

/// Widget poster gambar artikel — natural height, support offline (local file).
/// Berbeda dengan ArticleThumbnail: tidak ada overlay gelap, tidak fixed height.
class ArticlePosterWidget extends StatefulWidget {
  final String articleId;
  final String? networkUrl;

  const ArticlePosterWidget({
    super.key,
    required this.articleId,
    this.networkUrl,
  });

  @override
  State<ArticlePosterWidget> createState() => _ArticlePosterWidgetState();
}

class _ArticlePosterWidgetState extends State<ArticlePosterWidget> {
  String? _localPath;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadLocalPath();
  }

  Future<void> _loadLocalPath() async {
    final path = await OfflineArticleService.getPosterPath(widget.articleId);
    if (mounted) {
      setState(() {
        _localPath = path;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      // Placeholder sementara load path — pakai AspectRatio agar tidak layout shift besar
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      );
    }

    final Widget image;

    if (_localPath != null) {
      image = Image.file(
        File(_localPath!),
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (widget.networkUrl != null) {
      image = Image.network(
        widget.networkUrl!,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(color: AppColors.surfaceContainerLow),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: image,
    );
  }

  Widget _placeholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: AppColors.surfaceContainerLow,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 40.0,
            color: AppColors.onSurfaceVariant.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}

/// Widget thumbnail artikel yang support local file & network image.
/// Menggunakan StatefulWidget agar future hanya dibuat sekali, tidak tiap rebuild.
class ArticleThumbnail extends StatefulWidget {
  final String articleId;
  final String? networkUrl;
  final double height;
  final bool showPlayButton;

  const ArticleThumbnail({
    super.key,
    required this.articleId,
    this.networkUrl,
    this.height = 160.0,
    this.showPlayButton = false,
  });

  @override
  State<ArticleThumbnail> createState() => _ArticleThumbnailState();
}

class _ArticleThumbnailState extends State<ArticleThumbnail> {
  String? _localPath;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadLocalPath();
  }

  Future<void> _loadLocalPath() async {
    final path =
        await OfflineArticleService.getThumbnailPath(widget.articleId);
    if (mounted) {
      setState(() {
        _localPath = path;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Belum selesai load path
    if (!_loaded) {
      return Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16.0),
        ),
      );
    }

    Widget imageWidget;

    if (_localPath != null) {
      // Ada file lokal — pakai FileImage
      imageWidget = Image.file(
        File(_localPath!),
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (widget.networkUrl != null) {
      // Tidak ada lokal, pakai network
      imageWidget = Image.network(
        widget.networkUrl!,
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: widget.height,
            color: AppColors.surfaceContainerLow,
          );
        },
      );
    } else {
      // Tidak ada gambar sama sekali
      imageWidget = _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,
            // Overlay gelap
            Container(color: Colors.black.withOpacity(0.18)),
            // Tombol play (opsional)
            if (widget.showPlayButton)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: widget.height,
      color: AppColors.surfaceContainerLow,
      child: Center(
        child: Icon(
          Icons.article_outlined,
          size: 40.0,
          color: AppColors.onSurfaceVariant.withOpacity(0.3),
        ),
      ),
    );
  }
}
