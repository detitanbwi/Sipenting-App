import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/api_service.dart';

class TabHistory extends StatefulWidget {
  const TabHistory({super.key});

  @override
  State<TabHistory> createState() => _TabHistoryState();
}

class _TabHistoryState extends State<TabHistory> {
  bool _isLoading = true;
  List<dynamic> _children = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ApiService.getBayi();
      if (mounted) setState(() { _children = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  /// Map nilai status_stunting dari backend ke label + warna
  /// 1 = Sangat Pendek, 2 = Pendek, 3 = Normal, 4 = Terlalu Tinggi, null = Belum diukur
  ({String label, Color color, IconData icon}) _mapStatus(int? status) {
    switch (status) {
      case 1:
        return (
          label: 'Sangat Pendek (Stunting Berat)',
          color: AppColors.error,
          icon: Icons.arrow_downward_rounded,
        );
      case 2:
        return (
          label: 'Pendek (Stunting)',
          color: const Color(0xFFF57C00),
          icon: Icons.arrow_downward_rounded,
        );
      case 3:
        return (
          label: 'Tinggi Normal',
          color: const Color(0xFF388E3C),
          icon: Icons.check_circle_outline_rounded,
        );
      case 4:
        return (
          label: 'Terlalu Tinggi',
          color: const Color(0xFF1976D2),
          icon: Icons.arrow_upward_rounded,
        );
      default:
        return (
          label: 'Belum Ada Data Pengukuran',
          color: AppColors.onSurfaceVariant,
          icon: Icons.help_outline_rounded,
        );
    }
  }

  String _formatUmur(dynamic umur) {
    // Backend kirim umur sebagai array [tahun, bulan, hari]
    if (umur is List && umur.length >= 2) {
      final tahun = umur[0] as int? ?? 0;
      final bulan = umur[1] as int? ?? 0;
      if (tahun > 0 && bulan > 0) return '$tahun tahun $bulan bulan';
      if (tahun > 0) return '$tahun tahun';
      if (bulan > 0) return '$bulan bulan';
      final hari = umur.length >= 3 ? (umur[2] as int? ?? 0) : 0;
      return '$hari hari';
    }
    return '-';
  }

  String _formatKelamin(String? kelamin) {
    if (kelamin == null) return '-';
    final k = kelamin.toLowerCase();
    if (k == 'l' || k == 'laki-laki' || k == 'laki') return 'Laki-laki';
    if (k == 'p' || k == 'perempuan') return 'Perempuan';
    return kelamin;
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
                'Pantau Anak',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Status stunting terkini untuk setiap anak Anda.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24.0),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 56.0,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Gagal memuat data',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24.0),
            OutlinedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
              ),
            ),
          ],
        ),
      );
    }

    if (_children.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.child_care_rounded,
              size: 64.0,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Belum Ada Data Anak',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tambahkan data anak terlebih dahulu untuk memantau status stunting.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _children.length,
        itemBuilder: (context, index) {
          final child = _children[index] as Map<String, dynamic>;
          return _buildChildCard(child);
        },
      ),
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    final nama = child['nama'] as String? ?? '-';
    final kelamin = _formatKelamin(child['kelamin'] as String?);
    final umur = _formatUmur(child['umur']);
    final statusRaw = child['status_stunting'] as int?;
    final status = _mapStatus(statusRaw);
    final isPerempuan = (child['kelamin'] as String? ?? '').toLowerCase().startsWith('p');

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
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
          // Header: avatar + nama + kelamin
          Row(
            children: [
              CircleAvatar(
                radius: 22.0,
                backgroundColor: isPerempuan
                    ? const Color(0xFFFCE4EC)
                    : const Color(0xFFE3F2FD),
                child: Icon(
                  isPerempuan ? Icons.face_3_rounded : Icons.face_rounded,
                  color: isPerempuan
                      ? const Color(0xFFE91E63)
                      : const Color(0xFF1976D2),
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '$kelamin • $umur',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24.0, color: AppColors.surfaceContainerLow),

          // Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(status.icon, color: status.color, size: 16.0),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Stunting Terkini',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      status.label,
                      style: AppTypography.labelLarge.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Info jika belum pernah diukur
          if (statusRaw == null) ...[
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14.0,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Gunakan kalkulator stunting untuk mengukur status anak ini.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
