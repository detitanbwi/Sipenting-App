import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Dropdown States
  List<dynamic> _districts = [];
  List<dynamic> _villages = [];

  String? _selectedDistrictCode;
  String? _selectedVillageCode;

  bool _isLoadingDistricts = false;
  bool _isLoadingVillages = false;

  @override
  void initState() {
    super.initState();
    _fetchKecamatan();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchKecamatan() async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrictCode = null;
      _villages = [];
      _selectedVillageCode = null;
    });
    try {
      final data = await ApiService.getKecamatan();
      setState(() {
        _districts = data.map((item) {
          final id = item['id_kecamatan'] ?? item['id'] ?? item['code'];
          final name = item['nama_kecamatan'] ?? item['nama'] ?? item['name'];
          return {
            'code': id.toString(),
            'name': name.toString(),
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error fetching kecamatan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat kecamatan: ${e.toString().replaceFirst('Exception: ', '')}',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingDistricts = false;
      });
    }
  }

  Future<void> _fetchDesa(String districtCode) async {
    setState(() {
      _isLoadingVillages = true;
      _villages = [];
      _selectedVillageCode = null;
    });
    try {
      final data = await ApiService.getDesa(districtCode);
      setState(() {
        _villages = data.map((item) {
          final id = item['id_desa'] ?? item['id'] ?? item['code'];
          final name = item['nama_desa'] ?? item['nama'] ?? item['name'];
          return {
            'code': id.toString(),
            'name': name.toString(),
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error fetching villages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat desa: ${e.toString().replaceFirst('Exception: ', '')}',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingVillages = false;
      });
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.08),
                  blurRadius: 40.0,
                  offset: const Offset(0, 24),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green Circle with checkmark
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50),
                      size: 56.0,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Registrasi Berhasil',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  'Akun Anda berhasil didaftarkan. Silakan masuk dengan NIK dan kata sandi Anda.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    // Close the popup and go back to Login
                    Navigator.pop(context); // Pop dialog
                    Navigator.pop(context); // Pop register screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size.fromHeight(52.0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                  ),
                  child: Text(
                    'Masuk Sekarang',
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

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error),
              const SizedBox(width: 8.0),
              Text(title, style: AppTypography.titleLarge),
            ],
          ),
          content: Text(message, style: AppTypography.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tutup',
                style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(width: 20.0),
                  Text(
                    'Mendaftarkan Akun...',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDistrictCode == null || _selectedVillageCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Harap lengkapi pilihan Wilayah (Kecamatan, Desa)',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        );
        return;
      }

      _showProgressDialog();
      try {
        final username = _nikController.text.trim();
        final namaIbu = _nameController.text.trim();
        final idDesa = _selectedVillageCode!;

        await ApiService.register(
          username: username,
          namaIbu: namaIbu,
          idDesa: idDesa,
        );

        if (mounted) {
          Navigator.pop(context); // Close progress dialog
          _showSuccessPopup();
        }
      } on TimeoutException catch (_) {
        if (mounted) {
          Navigator.pop(context); // Close progress dialog
          _showErrorDialog(
            'Koneksi Lambat',
            'Waktu permintaan habis (timeout 10 detik). Harap periksa koneksi internet Anda.',
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close progress dialog
          final errorMessage = e.toString().replaceFirst('Exception: ', '');
          _showErrorDialog('Gagal Registrasi', errorMessage);
        }
      }
    }
  }

  Widget _buildDropdownDecoration({
    required Widget child,
    required String label,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 14.0,
                height: 14.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: DropdownButtonHideUnderline(child: child),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      'Mulai Perjalanan Anda',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Buat Akun Baru',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Daftarkan diri Anda untuk mengakses semua fitur pemantauan kesehatan.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 36.0),
                // Card containing Form inputs
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.onSurface.withValues(alpha: 0.03),
                        blurRadius: 24.0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name Field
                      Text(
                        'Nama Lengkap',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _nameController,
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Nama Lengkap Anda',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap masukkan nama lengkap Anda';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      // NIK Field
                      Text(
                        'Nomor Induk Kependudukan (NIK)',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _nikController,
                        style: AppTypography.bodyMedium,
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                        decoration: InputDecoration(
                          hintText: 'Masukkan 16 digit NIK',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap masukkan NIK Anda';
                          }
                          if (value.length != 16) {
                            return 'NIK harus terdiri dari 16 digit';
                          }
                          if (int.tryParse(value) == null) {
                            return 'NIK hanya boleh berisi angka';
                          }
                          return null;
                        },
                      ),
                      // Dropdown: Kecamatan
                      _buildDropdownDecoration(
                        label: 'Kecamatan',
                        isLoading: _isLoadingDistricts,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedDistrictCode,
                          hint: Text(
                            'Pilih Kecamatan',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.onSurfaceVariant,
                          ),
                          items: _districts.map<DropdownMenuItem<String>>((
                            dynamic item,
                          ) {
                            return DropdownMenuItem<String>(
                              value: item['code'],
                              child: Text(
                                item['name'] ?? '',
                                style: AppTypography.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? code) {
                            if (code != null) {
                              setState(() {
                                _selectedDistrictCode = code;
                              });
                              _fetchDesa(code);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // Dropdown: Desa
                      _buildDropdownDecoration(
                        label: 'Kelurahan / Desa',
                        isLoading: _isLoadingVillages,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedVillageCode,
                          disabledHint: Text(
                            'Pilih Kecamatan Terlebih Dahulu',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          hint: Text(
                            'Pilih Kelurahan / Desa',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.onSurfaceVariant,
                          ),
                          items: _villages.map<DropdownMenuItem<String>>((
                            dynamic item,
                          ) {
                            return DropdownMenuItem<String>(
                              value: item['code'],
                              child: Text(
                                item['name'] ?? '',
                                style: AppTypography.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: _selectedDistrictCode == null
                              ? null
                              : (String? code) {
                                  if (code != null) {
                                    setState(() {
                                      _selectedVillageCode = code;
                                    });
                                  }
                                },
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // Password Field
                      Text(
                        'Password',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Minimal 8 karakter',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap buat password Anda';
                          }
                          if (value.length < 8) {
                            return 'Password minimal 8 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      // Confirm Password Field
                      Text(
                        'Konfirmasi Password',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Ulangi password',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap ulangi password Anda';
                          }
                          if (value != _passwordController.text) {
                            return 'Password konfirmasi tidak cocok';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32.0),
                      // Register Button
                      ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          minimumSize: const Size.fromHeight(56.0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                        ),
                        child: Text(
                          'Daftar',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28.0),
                // Route back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Masuk Sekarang',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
