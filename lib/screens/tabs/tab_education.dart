import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/api_service.dart';
import '../../services/offline_article_service.dart';
import '../../widgets/article_thumbnail.dart';
import '../article_detail_screen.dart';

class TabEducation extends StatefulWidget {
  const TabEducation({super.key});

  @override
  State<TabEducation> createState() => _TabEducationState();
}

class _TabEducationState extends State<TabEducation> {
  // label tampilan → nilai API (null = semua, 'Tersimpan' = local storage)
  static const Map<String, String?> _categoryMap = {
    'Semua': null,
    'Remaja': 'Pencegahan',
    'Balita': 'Nutrisi',
    'Ibu Hamil': 'Edukasi',
    'Tersimpan': 'Tersimpan',
  };

  String _selectedCategory = 'Semua';
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _articles = [];
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<bool> _checkConnectivity() async {
    // connectivity_plus v6.x always returns List<ConnectivityResult>
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Tab Tersimpan: selalu dari local storage
    if (_selectedCategory == 'Tersimpan') {
      final saved = await OfflineArticleService.getSavedArticles();
      if (mounted) {
        setState(() {
          _articles = saved;
          _isLoading = false;
          _isOffline = false;
        });
      }
      return;
    }

    // Cek koneksi
    final isOnline = await _checkConnectivity();

    if (!isOnline) {
      // Offline: tampilkan artikel tersimpan sebagai fallback
      final saved = await OfflineArticleService.getSavedArticles();
      if (mounted) {
        setState(() {
          _articles = saved;
          _isLoading = false;
          _isOffline = true;
        });
      }
      return;
    }

    // Online: fetch dari API
    try {
      // Translate label tampilan ke nilai API yang dikenal backend
      final categoryParam = _categoryMap[_selectedCategory];
      final data = await ApiService.getArticles(category: categoryParam);
      if (mounted) {
        setState(() {
          _articles = data;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } catch (e) {
      // Gagal fetch: fallback ke offline
      final saved = await OfflineArticleService.getSavedArticles();
      if (mounted) {
        setState(() {
          _articles = saved;
          _isLoading = false;
          _isOffline = saved.isNotEmpty;
          _errorMessage = saved.isEmpty
              ? e.toString().replaceFirst('Exception: ', '')
              : null;
        });
      }
    }
  }

  /// Translate nilai kategori backend ke label tampilan
  static String _translateCategory(String raw) {
    switch (raw) {
      case 'Pencegahan': return 'Remaja';
      case 'Nutrisi':    return 'Balita';
      case 'Edukasi':    return 'Ibu Hamil';
      default:           return raw;
    }
  }

  int _calculateReadTime(String text) {
    final words = text.split(RegExp(r'\s+')).length;
    final minutes = (words / 150).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pusat Edukasi',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Pelajari tips nutrisi dan info kesehatan penting untuk tumbuh kembang anak.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20.0),

              // Horizontal Category Chips
              SizedBox(
                height: 40.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categoryMap.length,
                  itemBuilder: (context, index) {
                    final cat = _categoryMap.keys.elementAt(index);
                    final isSelected = _selectedCategory == cat;
                    final isSavedTab = cat == 'Tersimpan';
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSavedTab) ...[
                              Icon(
                                Icons.bookmark_rounded,
                                size: 13.0,
                                color: isSelected
                                    ? AppColors.onPrimary
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 4.0),
                            ],
                            Text(cat),
                          ],
                        ),
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat);
                          _fetchArticles();
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceContainerLow,
                        labelStyle: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.onPrimary
                              : AppColors.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            width: 1.0,
                          ),
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),

              // Offline / Tersimpan banner
              if (_isOffline)
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.orange,
                        size: 18.0,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Mode Offline — Menampilkan artikel yang tersimpan',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Article List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.wifi_off_rounded,
                                  size: 48.0,
                                  color: AppColors.onSurfaceVariant.withOpacity(0.4),
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                TextButton.icon(
                                  onPressed: _fetchArticles,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Coba Lagi'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _articles.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _selectedCategory == 'Tersimpan'
                                          ? Icons.bookmark_border_rounded
                                          : Icons.article_outlined,
                                      size: 48.0,
                                      color: AppColors.onSurfaceVariant.withOpacity(0.4),
                                    ),
                                    const SizedBox(height: 16.0),
                                    Text(
                                      _selectedCategory == 'Tersimpan'
                                          ? 'Belum ada artikel yang disimpan.\nBuka artikel dan tap ikon bookmark untuk menyimpannya.'
                                          : 'Tidak ada artikel ditemukan.',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _fetchArticles,
                                color: AppColors.primary,
                                child: ListView.builder(
                                  itemCount: _articles.length,
                                  itemBuilder: (context, index) {
                                    return _buildArticleCard(
                                      _articles[index] as Map<String, dynamic>,
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> item) {
    final String title = item['judul'] ?? '';
    final String desc = item['deskripsi'] ?? '';
    final String category = _translateCategory(item['kategori'] ?? 'Pencegahan');
    final String formattedDate = item['formatted_created_at'] ?? '';
    final String readTime = '${_calculateReadTime(desc)} Menit Baca';
    final String? urlVideo = item['url_video'] as String?;
    final String? videoId = (urlVideo != null && urlVideo.isNotEmpty)
        ? YoutubePlayer.convertUrlToId(urlVideo)
        : null;
    final String? gambar = item['gambar'] as String?;
    final bool hasPoster = gambar != null && gambar.isNotEmpty && gambar != 'gambar2';
    final String? posterUrl = hasPoster
        ? 'https://sipenting.bondowosokab.go.id/storage/artikel/$gambar'
        : null;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: item),
          ),
        );
        // Refresh jika user baru saja simpan/hapus dari detail screen
        if (_selectedCategory == 'Tersimpan') {
          _fetchArticles();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withOpacity(0.02),
              blurRadius: 16.0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    category,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSecondaryContainer,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  child: Text(
                    formattedDate.isNotEmpty
                        ? '$formattedDate • $readTime'
                        : readTime,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant.withOpacity(0.6),
                      fontSize: 11.0,
                    ),
                  ),
                ),
              ],
            ),
            // Tampilkan 1 gambar saja: YouTube thumb jika ada video, poster jika tidak
            if (videoId != null) ...[
              const SizedBox(height: 12.0),
              ArticleThumbnail(
                articleId: item['id']?.toString() ?? '',
                networkUrl: 'https://img.youtube.com/vi/$videoId/0.jpg',
                height: 160.0,
                showPlayButton: true,
              ),
            ] else if (hasPoster) ...[
              const SizedBox(height: 12.0),
              ArticleThumbnail(
                articleId: item['id']?.toString() ?? '',
                networkUrl: posterUrl,
                height: 160.0,
                showPlayButton: false,
              ),
            ],
            const SizedBox(height: 14.0),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              desc,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Baca Selengkapnya',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 16.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
