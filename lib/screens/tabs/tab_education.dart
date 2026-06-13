import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class TabEducation extends StatelessWidget {
  const TabEducation({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy articles data
    final articles = [
      {
        'title':
            '1000 Hari Pertama Kehidupan (HPK): Kunci Utama Cegah Stunting',
        'desc':
            'Kenapa 1000 HPK sangat vital? Cari tahu peran nutrisi penting bagi ibu hamil dan anak hingga usia 2 tahun di sini.',
        'category': 'Pencegahan',
        'readTime': '5 Menit Baca',
      },
      {
        'title': 'Menu MPASI Sehat dan Bergizi untuk Bayi Usia 6-12 Bulan',
        'desc':
            'Resep MPASI sederhana yang kaya akan zat besi, protein hewani, dan vitamin penting untuk menunjang tumbuh kembang optimal.',
        'category': 'Nutrisi',
        'readTime': '4 Menit Baca',
      },
      {
        'title':
            'Mitos dan Fakta Tentang Stunting yang Wajib Diketahui Orang Tua',
        'desc':
            'Apakah stunting murni faktor keturunan? Temukan jawaban ilmiah dan mitos-mitos yang selama ini beredar di masyarakat.',
        'category': 'Edukasi',
        'readTime': '3 Menit Baca',
      },
      {
        'title': 'Mengenal Tanda-Tanda Keterlambatan Tumbuh Kembang Anak',
        'desc':
            'Deteksi dini keterlambatan motorik dan sensorik anak. Ketahui kapan saat yang tepat untuk berkonsultasi dengan dokter anak.',
        'category': 'Kesehatan',
        'readTime': '6 Menit Baca',
      },
    ];

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
              const SizedBox(height: 24.0),
              Expanded(
                child: ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final item = articles[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 18.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24.0),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryFixed.withOpacity(
                                    0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  item['category']!,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.onSecondaryContainer,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                item['readTime']!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant.withOpacity(
                                    0.6,
                                  ),
                                  fontSize: 11.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            item['title']!,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            item['desc']!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Row(
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
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
