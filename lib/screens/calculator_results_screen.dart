import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class CalculatorResultsScreen extends StatelessWidget {
  final String childName;
  final Map<String, dynamic>? stuntingResult;

  const CalculatorResultsScreen({
    super.key,
    required this.childName,
    this.stuntingResult,
  });

  @override
  Widget build(BuildContext context) {
    final int statusVal = stuntingResult?['status'] ?? 3;
    final String rekomendasi = stuntingResult?['rekomendasi'] ?? 'Pertahankan pola makan dan pola asuh anak.';

    final String statusLabel;
    final Color statusColor;
    final IconData statusIcon;
    final String statusDesc;

    if (statusVal == 1) {
      statusLabel = 'Sangat Pendek';
      statusColor = AppColors.error;
      statusIcon = Icons.warning_rounded;
      statusDesc = 'Status tumbuh kembang anak menunjukkan kondisi sangat pendek. Diperlukan penanganan intensif.';
    } else if (statusVal == 2) {
      statusLabel = 'Pendek (Stunting)';
      statusColor = Colors.orange;
      statusIcon = Icons.warning_rounded;
      statusDesc = 'Status tumbuh kembang anak terindikasi pendek (stunting). Harap tingkatkan nutrisi dan pemantauan.';
    } else if (statusVal == 3) {
      statusLabel = 'Normal';
      statusColor = const Color(0xFF4CAF50);
      statusIcon = Icons.check_circle_rounded;
      statusDesc = 'Tumbuh kembang anak berada di jalur yang tepat. Pertahankan pola asuh dan nutrisi yang baik.';
    } else if (statusVal == 4) {
      statusLabel = 'Tinggi';
      statusColor = Colors.blue;
      statusIcon = Icons.info_rounded;
      statusDesc = 'Tinggi badan anak berada di atas rata-rata tinggi anak seusianya.';
    } else {
      statusLabel = 'Normal';
      statusColor = const Color(0xFF4CAF50);
      statusIcon = Icons.check_circle_rounded;
      statusDesc = 'Tumbuh kembang anak normal.';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hasil Analisis Stunting',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            // Hero Result Card
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor, statusColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.2),
                    blurRadius: 24.0,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: AppColors.onPrimary,
                      size: 48.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    statusLabel,
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    statusDesc,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onPrimary.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),
            
            Text(
              'Rekomendasi Petugas Kesehatan',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16.0),
            
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.03),
                    blurRadius: 20.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_turned_in_rounded, color: statusColor, size: 24.0),
                      const SizedBox(width: 8.0),
                      Text(
                        'Rekomendasi Tindakan',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    rekomendasi,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48.0),
            ElevatedButton(
              onPressed: () {
                // Return to home tab
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLowest,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                elevation: 0,
              ),
              child: Text(
                'Selesai & Kembali ke Beranda',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
