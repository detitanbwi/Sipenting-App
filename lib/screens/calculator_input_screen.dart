import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'calculator_results_screen.dart';
import '../services/api_service.dart';

class CalculatorInputScreen extends StatefulWidget {
  final int childId;
  final String childName;
  final String tanggalLahir;

  const CalculatorInputScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.tanggalLahir,
  });

  @override
  State<CalculatorInputScreen> createState() => _CalculatorInputScreenState();
}

class _CalculatorInputScreenState extends State<CalculatorInputScreen> {
  final _heightController = TextEditingController();

  String _selectedTab = 'tumbuh_kembang';

  bool _isLoadingFoods = true;
  List<dynamic> _foods = [];
  final Map<int, int> _nutritionPortions = {};

  // Custom icon mapping for database foods
  IconData _getFoodIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('pokok') || name.contains('nasi')) {
      return Icons.rice_bowl_rounded;
    } else if (name.contains('lauk') ||
        name.contains('lauk pauk') ||
        name.contains('ayam') ||
        name.contains('telur')) {
      return Icons.egg_alt_rounded;
    } else if (name.contains('sayur')) {
      return Icons.eco_rounded;
    } else if (name.contains('buah')) {
      return Icons.apple_rounded;
    } else if (name.contains('cairan') ||
        name.contains('air') ||
        name.contains('susu')) {
      return Icons.water_drop_rounded;
    }
    return Icons.restaurant_rounded;
  }

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    try {
      final data = await ApiService.getMakanan();
      setState(() {
        _foods = data;
        for (var food in _foods) {
          _nutritionPortions[food['id']] = 0;
        }
        _isLoadingFoods = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFoods = false;
      });
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _hitungStunting() async {
    final heightText = _heightController.text.trim();
    if (heightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan tinggi/panjang badan anak'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final response = await ApiService.cekStuntingAnak(
        idBayi: widget.childId.toString(),
        tinggiBadan: heightText,
      );
      Navigator.pop(context); // Close loading dialog

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalculatorResultsScreen(
              childName: widget.childName,
              stuntingResult: response['data'],
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _hitungNutrisi() async {
    // Validasi umur: hitung dari tanggalLahir, harus 6-59 bulan
    final tgl = DateTime.tryParse(widget.tanggalLahir);
    if (tgl != null) {
      final now = DateTime.now();
      final umurBulan =
          (now.year - tgl.year) * 12 + (now.month - tgl.month);
      if (umurBulan < 6 || umurBulan > 59) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 24.0),
                const SizedBox(width: 8.0),
                const Text('Tidak Dapat Dihitung'),
              ],
            ),
            content: Text(
              'Kalkulator nutrisi hanya tersedia untuk anak usia 6–59 bulan. '
              'Usia ${widget.childName} saat ini $umurBulan bulan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Mengerti'),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Validasi: minimal 1 item harus > 0
    final hasInput = _nutritionPortions.values.any((v) => v > 0);
    if (!hasInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi minimal satu porsi makanan terlebih dahulu'),
        ),
      );
      return;
    }

    // Construct [[id_makanan, jumlah], ...]
    final List<List<int>> dataArray = [];
    _nutritionPortions.forEach((foodId, portion) {
      dataArray.add([foodId, portion]);
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final response = await ApiService.cekGizi(
        idBayi: widget.childId.toString(),
        data: jsonEncode(dataArray),
      );
      Navigator.pop(context); // Close loading dialog

      final List<dynamic> results = response['data'] ?? [];

      // Backend mengembalikan peringatan jika umur di luar range 6-59 bulan
      final isWarning = results.isNotEmpty &&
          (results[0]['makanan'] ?? '') == 'Peringatan!';

      if (!mounted) return;

      if (isWarning) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 24.0),
                const SizedBox(width: 8.0),
                const Text('Tidak Dapat Dihitung'),
              ],
            ),
            content: Text(
              results[0]['keterangan'] ?? 'Umur anak di luar rentang yang didukung.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Mengerti'),
              ),
            ],
          ),
        );
        return;
      }

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (_, scrollController) => Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Hasil Analisis Nutrisi',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final res = results[index];
                        final foodName = res['makanan'] ?? '';
                        final keterangan = res['keterangan'] ?? '';
                        final kecukupan = res['kecukupan'] ?? 1;

                        Color statusColor = AppColors.error;
                        if (kecukupan == 2) {
                          statusColor = const Color(0xFF4CAF50); // Cukup
                        } else if (kecukupan == 3) {
                          statusColor = Colors.orange; // Berlebih
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          color: AppColors.surfaceContainerLowest,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        foodName,
                                        style: AppTypography.titleMedium
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      child: Text(
                                        keterangan.split('!')[0],
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (keterangan.contains('!')) ...[
                                  const SizedBox(height: 8.0),
                                  Text(
                                    keterangan
                                        .substring(keterangan.indexOf('!') + 1)
                                        .trim(),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Data Pengukuran',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.face_rounded,
                          color: AppColors.primary,
                          size: 24.0,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mengukur untuk profil:',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              widget.childName,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.swap_horiz_rounded,
                            color: AppColors.primary,
                            size: 20.0,
                          ),
                          Text(
                            'Ganti Anak',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Segmented Tab Selector
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        label: 'Tumbuh Kembang',
                        tabName: 'tumbuh_kembang',
                        icon: Icons.show_chart_rounded,
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        label: 'Nutrisi',
                        tabName: 'nutrisi',
                        icon: Icons.restaurant_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              if (_selectedTab == 'tumbuh_kembang') ...[
                Text(
                  'Tinggi/Panjang Badan (cm)',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12.0),
                _buildInputField(
                  controller: _heightController,
                  hint: 'Contoh: 85.0',
                  icon: Icons.height_rounded,
                ),
                const SizedBox(height: 32.0),

                ElevatedButton(
                  onPressed: _hitungStunting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Hitung Status Gizi',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  'Kalkulator Nutrisi',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  'Input porsi makanan & minuman yang dikonsumsi hari ini.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24.0),

                _isLoadingFoods
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : Column(
                        children: _foods.map((food) {
                          final int id = food['id'];
                          final String name = food['nama'] ?? '';
                          final String desc = food['deskripsi'] ?? '';
                          final String satuan = food['satuan'] ?? '';
                          return _buildNutritionItem(id, name, desc, satuan);
                        }).toList(),
                      ),
                const SizedBox(height: 32.0),

                ElevatedButton(
                  onPressed: _hitungNutrisi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Hitung Status Nutrisi',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionItem(int id, String name, String subtitle, String satuan) {
    final portion = _nutritionPortions[id] ?? 0;
    final icon = _getFoodIcon(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22.0),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6.0),
                      Text(
                        subtitle,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(
              height: 1.0,
              thickness: 1.0,
              color: AppColors.outlineVariant.withOpacity(0.3),
            ),
          ),
          Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: portion > 0
                    ? () {
                        setState(() {
                          _nutritionPortions[id] = portion - 1;
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: AppColors.primary,
                disabledColor: AppColors.outlineVariant,
                iconSize: 28.0,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16.0),
              Column(
                children: [
                  Text(
                    '$portion',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (satuan.isNotEmpty)
                    Text(
                      satuan,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
              const SizedBox(width: 16.0),
              IconButton(
                onPressed: () {
                  setState(() {
                    _nutritionPortions[id] = portion + 1;
                  });
                },
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: AppColors.primary,
                iconSize: 28.0,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTypography.bodyLarge.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyLarge.copyWith(
            color: AppColors.onSurfaceVariant.withOpacity(0.5),
          ),
          prefixIcon: Icon(icon, color: AppColors.outline),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required String tabName,
    required IconData icon,
  }) {
    final isSelected = _selectedTab == tabName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.onSurface.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.0,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant.withOpacity(0.8),
                fontSize: 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
