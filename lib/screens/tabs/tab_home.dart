import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../calculator_select_profile_screen.dart';
import '../children_management_screen.dart';
import '../../services/api_service.dart';
import '../../services/offline_article_service.dart';
import '../../widgets/article_thumbnail.dart';
import '../article_detail_screen.dart';

class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  bool _isLoading = true;
  String _namaIbu = 'Ibu';
  List<dynamic> _children = [];
  List<dynamic> _articles = [];
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<bool> _checkConnectivity() async {
    // connectivity_plus v6.x always returns List<ConnectivityResult>
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _loadDashboardData() async {
    final isOnline = await _checkConnectivity();

    if (!isOnline) {
      // Offline: load artikel tersimpan saja, data user/anak tidak bisa diupdate
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

    try {
      final results = await Future.wait([
        ApiService.getUser(),
        ApiService.getBayi(),
        ApiService.getArticles(),
      ]);

      if (mounted) {
        setState(() {
          _namaIbu = (results[0] as Map<String, dynamic>)['namaIbu'] ?? 'Ibu';
          _children = results[1] as List<dynamic>;
          _articles = results[2] as List<dynamic>;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } catch (e) {
      // Gagal fetch: fallback ke artikel tersimpan
      final saved = await OfflineArticleService.getSavedArticles();
      if (mounted) {
        setState(() {
          _articles = saved;
          _isLoading = false;
          _isOffline = saved.isNotEmpty;
        });
      }
    }
  }

  String _formatAge(List<dynamic>? umur) {
    if (umur == null || umur.length < 2) return 'Baru Lahir';
    final years = umur[0] as int;
    final months = umur[1] as int;
    if (years > 0) {
      return '$years Tahun $months Bulan';
    }
    return '$months Bulan';
  }

  int _calculateReadTime(String text) {
    final words = text.split(RegExp(r'\s+')).length;
    final minutes = (words / 150).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting & Header Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Pagi, Ibu',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      _isLoading
                          ? const SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: AppColors.primary,
                              ),
                            )
                          : Text(
                              _namaIbu,
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 28.0,
                  backgroundColor: AppColors.secondaryContainer,
                  child: const Icon(
                    Icons.face_3_rounded,
                    color: AppColors.onSecondaryContainer,
                    size: 32.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28.0),
  
            // Overview Health Card (Asymmetric Design)
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 24.0,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Tumbuh Kembang',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.onPrimary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Semua Buah Hati dalam Keadaan Sehat',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.secondaryContainer,
                          size: 18.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'Posyandu berikutnya : 18 Juni 2026',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28.0),
  
            // Quick Action Grid
            Text(
              'Layanan Pintar',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: _buildServiceCard(
                    icon: Icons.calculate_outlined,
                    title: 'Kalkulator Gizi',
                    subtitle: 'Cek stunting anak',
                    color: const Color(0xFFE0F2F1),
                    iconColor: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalculatorSelectProfileScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildServiceCard(
                    icon: Icons.child_care_rounded,
                    title: 'Kelola Anak',
                    subtitle: 'Ubah data balita',
                    color: const Color(0xFFFFFDE7),
                    iconColor: AppColors.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChildrenManagementScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28.0),
  
            // Horizontal Child Profiles list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data Buah Hati Anda',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChildrenManagementScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Lihat Semua',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            _buildChildrenSection(),
            const SizedBox(height: 28.0),
  
            // Recent Articles list
            Text(
              'Edukasi',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildArticlesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenSection() {
    if (_isLoading) {
      return const SizedBox(
        height: 140.0,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_children.isEmpty) {
      return Container(
        height: 140.0,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: Text(
          'Belum ada data buah hati terdaftar.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    return SizedBox(
      height: 140.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _children.length,
        itemBuilder: (context, index) {
          final child = _children[index];
          final String name = child['nama'] ?? '';
          final String age = _formatAge(child['umur']);
          
          final String status;
          final Color statusColor;
          final int? statusStunting = child['status_stunting'];
          
          if (statusStunting == 1) {
            status = 'Sangat Pendek';
            statusColor = AppColors.error;
          } else if (statusStunting == 2) {
            status = 'Pendek (Stunting)';
            statusColor = Colors.orange;
          } else if (statusStunting == 3) {
            status = 'Normal';
            statusColor = const Color(0xFF4CAF50);
          } else if (statusStunting == 4) {
            status = 'Tinggi';
            statusColor = Colors.blue;
          } else {
            status = 'Belum Cek';
            statusColor = AppColors.outline;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildChildCard(
              name: name,
              age: age,
              status: status,
              statusColor: statusColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticlesSection() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_articles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16.0),
        ),
        alignment: Alignment.center,
        child: Text(
          'Belum ada artikel terkini.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    // Show top 2 latest articles
    final displayList = _articles.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isOffline)
          Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.orange.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 16.0),
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
        ...displayList.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildArticleItem(item),
          );
        }),
      ],
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: iconColor.withOpacity(0.25), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard({
    required String name,
    required String age,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      width: 240.0, // Increased width to prevent text overflow
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.0),
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
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            age,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleItem(Map<String, dynamic> item) {
    final String title = item['judul'] ?? '';
    final String category = item['kategori'] ?? 'Pencegahan';
    final String desc = item['deskripsi'] ?? '';
    final String readTime = '${_calculateReadTime(desc)} Menit Baca';
    final String? urlVideo = item['url_video'];
    final String? videoId = (urlVideo != null && urlVideo.isNotEmpty) ? YoutubePlayer.convertUrlToId(urlVideo) : null;
    final String? gambar = item['gambar'] as String?;
    final bool hasPoster = gambar != null && gambar.isNotEmpty && gambar != 'gambar2';
    final String? posterUrl = hasPoster
        ? 'https://sipenting.bondowosokab.go.id/storage/artikel/$gambar'
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: item),
          ),
        );
      },
      child: Container(
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
                    readTime,
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
            const SizedBox(height: 16.0),
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
