import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class TabHome extends StatelessWidget {
  const TabHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    Text(
                      'Rina Wijaya',
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
                  color: AppColors.primary.withValues(alpha: 0.15),
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
                  onTap: () {},
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
                  onTap: () {},
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
                onPressed: () {},
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
          SizedBox(
            height: 140.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                _buildChildCard(
                  name: 'Ahmad Wijaya',
                  age: '2 Tahun 3 Bulan',
                  status: 'Gizi Baik (Normal)',
                  statusColor: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 16.0),
                _buildChildCard(
                  name: 'Siti Rahma',
                  age: '8 Bulan',
                  status: 'Perlu Perhatian (Kurus)',
                  statusColor: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28.0),

          // Recent Articles list
          Text(
            'Artikel & Tips Terkini',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildArticleItem(
            title: 'Mencegah Stunting Sejak 1000 Hari Pertama Kehidupan anak',
            category: 'Pencegahan',
            readTime: '5 Mnt Baca',
          ),
          const SizedBox(height: 12.0),
          _buildArticleItem(
            title:
                'Pentingnya ASI Eksklusif dan Cara Memenuhi Nutrisi Ibu Menyusui',
            category: 'Nutrisi',
            readTime: '3 Mnt Baca',
          ),
        ],
      ),
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
      width: 220.0,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.02),
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

  Widget _buildArticleItem({
    required String title,
    required String category,
    required String readTime,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.02),
            blurRadius: 16.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        category,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSecondaryContainer,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      readTime,
                      style: AppTypography.bodySmall.copyWith(fontSize: 10.0),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          Container(
            width: 70.0,
            height: 70.0,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Icon(
              Icons.article_outlined,
              color: AppColors.primary,
              size: 28.0,
            ),
          ),
        ],
      ),
    );
  }
}
