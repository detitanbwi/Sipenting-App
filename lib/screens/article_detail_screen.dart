import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  YoutubePlayerController? _youtubeController;
  bool _hasVideo = false;

  @override
  void initState() {
    super.initState();
    final urlVideo = widget.article['url_video'] as String?;
    if (urlVideo != null && urlVideo.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(urlVideo);
      if (videoId != null) {
        _hasVideo = true;
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
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
  }

  @override
  void deactivate() {
    // Pauses video on page navigation/backgrounding
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

  @override
  Widget build(BuildContext context) {
    final title = widget.article['judul'] ?? '';
    final category = widget.article['kategori'] ?? 'Pencegahan';
    final desc = widget.article['deskripsi'] ?? '';
    final formattedDate = widget.article['formatted_created_at'] ?? '';
    final readTime = '${_calculateReadTime(desc)} Menit Baca';

    Widget buildScaffold({Widget? player}) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
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
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Video Player Section if video exists
                if (_hasVideo && player != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                else if (widget.article['gambar'] != null &&
                    (widget.article['gambar'] as String).isNotEmpty &&
                    widget.article['gambar'] != 'gambar2') // Handle dummy/placeholder image
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      image: DecorationImage(
                        image: NetworkImage(widget.article['gambar']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // Content Details
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta Category & Read Time
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
                          Text(
                            formattedDate.isNotEmpty ? '$formattedDate • $readTime' : readTime,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18.0),

                      // Article Title
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

                      // Article Description
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

    if (_hasVideo && _youtubeController != null) {
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
