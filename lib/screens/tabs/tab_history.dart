import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class TabHistory extends StatelessWidget {
  const TabHistory({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy measurements data
    final List<Map<String, dynamic>> measurements = [
      {
        'child': 'Ahmad Wijaya',
        'date': '10 Mei 2026',
        'height': '88.5 cm',
        'weight': '12.4 kg',
        'status': 'Tinggi Normal',
        'statusColor': const Color(0xFF4CAF50),
      },
      {
        'child': 'Siti Rahma',
        'date': '08 Mei 2026',
        'height': '68.0 cm',
        'weight': '7.1 kg',
        'status': 'Tinggi Kurang (Stunting)',
        'statusColor': AppColors.error,
      },
      {
        'child': 'Ahmad Wijaya',
        'date': '12 April 2026',
        'height': '87.2 cm',
        'weight': '12.1 kg',
        'status': 'Tinggi Normal',
        'statusColor': const Color(0xFF4CAF50),
      },
      {
        'child': 'Siti Rahma',
        'date': '06 April 2026',
        'height': '67.1 cm',
        'weight': '6.9 kg',
        'status': 'Tinggi Kurang (Stunting)',
        'statusColor': AppColors.error,
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
                'Riwayat Pengukuran',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Daftar riwayat pengukuran tinggi dan berat badan buah hati Anda.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24.0),
              Expanded(
                child: ListView.builder(
                  itemCount: measurements.length,
                  itemBuilder: (context, index) {
                    final item = measurements[index];
                    final String childName = item['child'] as String;
                    final String dateStr = item['date'] as String;
                    final String heightStr = item['height'] as String;
                    final String weightStr = item['weight'] as String;
                    final String statusStr = item['status'] as String;
                    final Color statusColor = item['statusColor'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.all(18.0),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                childName,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                dateStr,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant.withOpacity(
                                    0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 24.0,
                            color: AppColors.surfaceContainerLow,
                          ),
                          Row(
                            children: [
                              _buildMetric(Icons.height, 'Tinggi', heightStr),
                              const SizedBox(width: 32.0),
                              _buildMetric(
                                Icons.monitor_weight_outlined,
                                'Berat',
                                weightStr,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: statusColor,
                                  size: 14.0,
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  statusStr,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
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

  Widget _buildMetric(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6.0),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 16.0),
        ),
        const SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
