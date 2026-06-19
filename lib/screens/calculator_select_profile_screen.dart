import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'calculator_input_screen.dart';
import '../services/api_service.dart';

class CalculatorSelectProfileScreen extends StatefulWidget {
  const CalculatorSelectProfileScreen({super.key});

  @override
  State<CalculatorSelectProfileScreen> createState() => _CalculatorSelectProfileScreenState();
}

class _CalculatorSelectProfileScreenState extends State<CalculatorSelectProfileScreen> {
  bool _isLoading = true;
  List<dynamic> _children = [];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final data = await ApiService.getBayi();
      setState(() {
        _children = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
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
          'Kalkulator Gizi',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                children: [
                  Text(
                    'Pilih Profil\nAnak Anda',
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Pilih data anak yang ingin Anda hitung dan pantau status gizinya saat ini.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  if (_children.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Belum ada data anak terdaftar. Harap tambahkan data anak di menu Kelola Anak terlebih dahulu.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    )
                  else
                    ..._children.map((child) {
                      final int childId = child['id'];
                      final String name = child['nama'] ?? '';
                      final String age = _formatAge(child['umur']);
                      final String gender = child['kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildProfileSelectionCard(
                          context: context,
                          childId: childId,
                          name: name,
                          age: age,
                          gender: gender,
                        ),
                      );
                    }),
                  
                  const SizedBox(height: 32.0),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileSelectionCard({
    required BuildContext context,
    required int childId,
    required String name,
    required String age,
    required String gender,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalculatorInputScreen(
              childId: childId,
              childName: name,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withOpacity(0.03),
              blurRadius: 20.0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Icon(
                gender == 'Laki-laki' ? Icons.face_rounded : Icons.face_3_rounded,
                color: AppColors.secondary,
                size: 32.0,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    age,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
