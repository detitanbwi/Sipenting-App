import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Asymmetric / Editorial Brand Header
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.onSurface.withOpacity(0.04),
                        blurRadius: 32.0,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo_sipenting.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image has loading/reading issue
                      return const Icon(
                        Icons.child_care_rounded,
                        size: 80,
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              Text(
                'SiPenTing',
                textAlign: TextAlign.center,
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Sistem Peduli Stunting',
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Pendamping digital terpercaya bagi keluarga untuk memantau tumbuh kembang anak secara tepat, ramah, dan interaktif.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Soft CTA Button Area
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size.fromHeight(56.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.0), // Pill format
                  ),
                ),
                child: Text(
                  'Mulai Sekarang',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Kolaborasi antara Pemerintah Kabupaten Bondowoso & Universitas Jember',
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Versi 2',
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
