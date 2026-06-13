import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class TabProfile extends StatelessWidget {
  const TabProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Profil Pengguna',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24.0),
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(24.0),
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36.0,
                      backgroundColor: AppColors.secondaryFixed,
                      child: const Icon(
                        Icons.face_3_rounded,
                        color: AppColors.onSecondaryContainer,
                        size: 44.0,
                      ),
                    ),
                    const SizedBox(width: 18.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rina Wijaya',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'NIK: 3511094602910003',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Detail Location Information Card
              Text(
                'Informasi Wilayah',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Kabupaten', 'Kabupaten Bondowoso'),
                    const Divider(
                      height: 24.0,
                      color: AppColors.outlineVariant,
                    ),
                    _buildInfoRow('Kecamatan', 'Kecamatan Curahdami'),
                    const Divider(
                      height: 24.0,
                      color: AppColors.outlineVariant,
                    ),
                    _buildInfoRow('Desa / Kelurahan', 'Desa Curahdami'),
                  ],
                ),
              ),
              const SizedBox(height: 28.0),

              // Menu Settings Actions
              Text(
                'Pengaturan & Layanan',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),
              Container(
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
                  children: [
                    _buildMenuTile(
                      Icons.settings_outlined,
                      'Pengaturan Akun',
                      () {},
                    ),
                    _buildMenuTile(
                      Icons.notifications_none_rounded,
                      'Notifikasi',
                      () {},
                    ),
                    _buildMenuTile(
                      Icons.headset_mic_outlined,
                      'Hubungi Petugas Posyandu',
                      () {},
                    ),
                    _buildMenuTile(
                      Icons.info_outline_rounded,
                      'Tentang Aplikasi',
                      () {
                        _showAboutDialog(context);
                      },
                    ),
                    const Divider(
                      height: 1.0,
                      color: AppColors.surfaceContainerLow,
                    ),
                    _buildMenuTile(
                      Icons.logout_rounded,
                      'Keluar dari Aplikasi',
                      () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      isDanger: true,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDanger = false,
  }) {
    final color = isDanger ? AppColors.error : AppColors.onSurface;
    return ListTile(
      leading: Icon(icon, color: color, size: 22.0),
      title: Text(
        label,
        style: AppTypography.titleMedium.copyWith(
          color: color,
          fontWeight: isDanger ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.onSurfaceVariant,
        size: 20.0,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 4.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withOpacity(0.08),
                  blurRadius: 40.0,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo
                Container(
                  width: 90.0,
                  height: 90.0,
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/logo_sipenting.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.child_care_rounded,
                      size: 48.0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 18.0),
                Text(
                  'SiPenTing',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Versi 2',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Sistem Informasi Cegah & Pantau Stunting (SiPenTing) adalah aplikasi pemantauan kesehatan gizi anak secara praktis, terukur, dan interaktif.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20.0),
                const Divider(
                  color: AppColors.surfaceContainerLow,
                  height: 1.0,
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Tim Pengembang',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Hasil Kerja Sama antara:\nPemerintah Kabupaten Bondowoso\n&\nUniversitas Jember',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurface,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28.0),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size.fromHeight(48.0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
