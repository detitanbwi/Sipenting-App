import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/offline_article_service.dart';
import '../widgets/article_thumbnail.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  YoutubePlayerController? _youtubeController;
  bool _hasVideo = false;
  bool _isSaved = false;
  bool _isSaving = false;
  String? _videoId;
  bool _isOnline = true; // asumsi online dulu, update di initState

  @override
  void initState() {
    super.initState();
    final urlVideo = widget.article['url_video'] as String?;
    if (urlVideo != null && urlVideo.isNotEmpty) {
      final vid = YoutubePlayer.convertUrlToId(urlVideo);
      if (vid != null) {
        _videoId = vid;
        _hasVideo = true;
        _youtubeController = YoutubePlayerController(
          initialVideoId: vid,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: true,
          ),
        );
      }
    }
    _checkIfSaved();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    // connectivity_plus v6.x always returns List<ConnectivityResult>
    final results = await Connectivity().checkConnectivity();
    final online = results.any((r) => r != ConnectivityResult.none);
    if (mounted) setState(() => _isOnline = online);
  }

  Future<void> _checkIfSaved() async {
    final id = widget.article['id']?.toString();
    if (id == null) return;
    final saved = await OfflineArticleService.isArticleSaved(id);
    if (mounted) setState(() => _isSaved = saved);
  }

  Future<void> _toggleSave() async {
    final id = widget.article['id']?.toString();
    if (id == null) return;

    setState(() => _isSaving = true);

    try {
      if (_isSaved) {
        await OfflineArticleService.deleteArticle(id);
        if (mounted) {
          setState(() {
            _isSaved = false;
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Artikel dihapus dari tersimpan'),
              backgroundColor: AppColors.onSurface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
          );
        }
      } else {
        await OfflineArticleService.saveArticle(widget.article);
        if (mounted) {
          setState(() {
            _isSaved = true;
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Artikel berhasil disimpan untuk dibaca offline'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan artikel: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
          ),
        );
      }
    }
  }

  @override
  void deactivate() {
    _youtubeController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  int _calculateReadTime(String text) {
    final words = text.split(RegExp(r'\s+')).length;
    final minutes = (words / 150).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  String _translateCategory(String raw) {
    switch (raw) {
      case 'Pencegahan': return 'Remaja';
      case 'Nutrisi':    return 'Balita';
      case 'Edukasi':    return 'Ibu Hamil';
      default:           return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.article['judul'] ?? '';
    final category = _translateCategory(widget.article['kategori'] ?? '');
    final desc = widget.article['deskripsi'] ?? '';
    final formattedDate = widget.article['formatted_created_at'] ?? '';
    final readTime = '${_calculateReadTime(desc)} Menit Baca';
    final articleId = widget.article['id']?.toString() ?? '';
    final gambar = widget.article['gambar'] as String?;
    final hasPoster = gambar != null && gambar.isNotEmpty && gambar != 'gambar2';
    // Konstruksi full URL poster dari nama file backend
    final posterUrl = hasPoster
        ? 'https://sipenting.bondowosokab.go.id/storage/artikel/$gambar'
        : null;
    // URL thumbnail YouTube untuk ditampilkan saat offline
    final videoThumbnailUrl = _videoId != null
        ? 'https://img.youtube.com/vi/$_videoId/0.jpg'
        : null;

    Widget buildScaffold({Widget? player}) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Detail Edukasi',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        _isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: _isSaved
                            ? AppColors.primary
                            : AppColors.onSurface,
                      ),
                      onPressed: _toggleSave,
                      tooltip:
                          _isSaved ? 'Hapus dari tersimpan' : 'Simpan artikel',
                    ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Online + ada video: tampilkan YouTube player
                if (_hasVideo && _isOnline && player != null)
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: player,
                  )
                // 1b. Offline + ada video: tampilkan thumbnail YouTube lokal (tanpa overlay)
                else if (_hasVideo && !_isOnline)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: ArticleThumbnail(
                        articleId: articleId,
                        networkUrl: videoThumbnailUrl,
                        height: 220,
                        showPlayButton: false,
                      ),
                    ),
                  ),

                // Content Details
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Meta: kategori & waktu baca
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryFixed.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              category,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Flexible(
                            child: Text(
                              formattedDate.isNotEmpty
                                  ? '$formattedDate • $readTime'
                                  : readTime,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color:
                                    AppColors.onSurfaceVariant.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18.0),

                      // 3. Judul artikel
                      Text(
                        title,
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Divider(color: AppColors.outlineVariant),
                      const SizedBox(height: 16.0),

                      // 4. Poster gambar artikel — selalu tampil jika ada, online maupun offline
                      if (hasPoster) ...[
                        ArticlePosterWidget(
                          articleId: articleId,
                          networkUrl: posterUrl,
                        ),
                        const SizedBox(height: 20.0),
                      ],

                      // 5. Isi / deskripsi
                      Text(
                        desc,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_hasVideo && _isOnline && _youtubeController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primary,
          progressColors: const ProgressBarColors(
            playedColor: AppColors.primary,
            handleColor: AppColors.primary,
          ),
        ),
        builder: (context, player) {
          return buildScaffold(player: player);
        },
      );
    } else {
      return buildScaffold();
    }
  }
}
