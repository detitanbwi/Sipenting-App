import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/api_service.dart';
import '../login_screen.dart';

class TabProfile extends StatefulWidget {
  const TabProfile({super.key});

  @override
  State<TabProfile> createState() => _TabProfileState();
}

class _TabProfileState extends State<TabProfile> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ApiService.getUser();
      if (mounted) setState(() { _userData = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _showEditProfileSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileSheet(userData: _userData ?? {}),
    );
    if (result == true) _loadUserData();
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        title: Text(
          'Keluar dari Aplikasi?',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Anda akan keluar dari akun ini. Data tersimpan lokal tidak akan terhapus.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: AppTypography.labelLarge.copyWith(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Keluar',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _errorMessage != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56.0, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16.0),
            Text(
              'Gagal memuat profil',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24.0),
            OutlinedButton.icon(
              onPressed: _loadUserData,
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
      ),
    );
  }

  Widget _buildContent() {
    final namaIbu = _userData?['namaIbu'] ?? '-';
    final nik = _userData?['nik'] ?? _userData?['username'] ?? '-';
    final tanggalLahir = _userData?['tanggalLahir'] ?? '-';
    final tinggiBadan = _userData?['tinggiBadan']?.toString() ?? '-';
    final bbPraHamil = _userData?['bbPraHamil']?.toString() ?? '-';

    return SingleChildScrollView(
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
                  child: Text(
                    namaIbu.isNotEmpty ? namaIbu[0].toUpperCase() : '?',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 18.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaIbu,
                        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'NIK: $nik',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _showEditProfileSheet,
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'Edit Profil',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Data Pribadi
          Text(
            'Data Pribadi',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
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
                _buildInfoRow('Tanggal Lahir', tanggalLahir != '-' ? _formatDate(tanggalLahir) : '-'),
                const Divider(height: 24.0, color: AppColors.outlineVariant),
                _buildInfoRow('Tinggi Badan', tinggiBadan != '-' ? '$tinggiBadan cm' : '-'),
                const Divider(height: 24.0, color: AppColors.outlineVariant),
                _buildInfoRow('BB Pra Hamil', bbPraHamil != '-' ? '$bbPraHamil kg' : '-'),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Informasi Wilayah
          Text(
            'Informasi Wilayah',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
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
                _buildInfoRow('Kabupaten', 'Bondowoso'),
                const Divider(height: 24.0, color: AppColors.outlineVariant),
                _buildInfoRow('Kode Wilayah', _userData?['id_villages']?.toString() ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: 28.0),

          // Menu Layanan
          Text(
            'Pengaturan & Layanan',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
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
                  Icons.person_outline_rounded,
                  'Edit Profil',
                  _showEditProfileSheet,
                ),
                _buildMenuTile(
                  Icons.info_outline_rounded,
                  'Tentang Aplikasi',
                  () => _showAboutDialog(context),
                ),
                const Divider(height: 1.0, color: AppColors.surfaceContainerLow),
                _buildMenuTile(
                  Icons.logout_rounded,
                  'Keluar dari Aplikasi',
                  _confirmLogout,
                  isDestructive: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    // Backend menyimpan format YYYY-MM-DD
    try {
      final parts = raw.split('-');
      if (parts.length == 3) {
        const months = [
          '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        final m = int.tryParse(parts[1]) ?? 0;
        return '${parts[2]} ${m > 0 && m <= 12 ? months[m] : parts[1]} ${parts[0]}';
      }
    } catch (_) {}
    return raw;
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(width: 16.0),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? AppColors.error : AppColors.onSurface;
    return ListTile(
      leading: Icon(icon, color: color, size: 22.0),
      title: Text(title, style: AppTypography.bodyLarge.copyWith(color: color)),
      trailing: Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.4), size: 20.0),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(28.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.08),
                blurRadius: 40.0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
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
              const Divider(color: AppColors.surfaceContainerLow, height: 1.0),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                ),
                child: Text('Tutup', style: AppTypography.labelLarge.copyWith(color: AppColors.onPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit Profile Bottom Sheet
// ---------------------------------------------------------------------------
class _EditProfileSheet extends StatefulWidget {
  final Map<String, dynamic> userData;
  const _EditProfileSheet({required this.userData});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaIbuCtrl;
  late TextEditingController _tanggalLahirCtrl;
  late TextEditingController _tinggiBadanCtrl;
  late TextEditingController _bbPraHamilCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaIbuCtrl = TextEditingController(text: widget.userData['namaIbu'] ?? '');
    _tanggalLahirCtrl = TextEditingController(text: widget.userData['tanggalLahir'] ?? '');
    _tinggiBadanCtrl = TextEditingController(text: widget.userData['tinggiBadan']?.toString() ?? '');
    _bbPraHamilCtrl = TextEditingController(text: widget.userData['bbPraHamil']?.toString() ?? '');
  }

  @override
  void dispose() {
    _namaIbuCtrl.dispose();
    _tanggalLahirCtrl.dispose();
    _tinggiBadanCtrl.dispose();
    _bbPraHamilCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime initial;
    try {
      initial = DateTime.parse(_tanggalLahirCtrl.text);
    } catch (_) {
      initial = DateTime(now.year - 25);
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => _tanggalLahirCtrl.text = formatted);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.updateProfile(
        username: widget.userData['username'] ?? widget.userData['nik'] ?? '',
        namaIbu: _namaIbuCtrl.text.trim(),
        tanggalLahir: _tanggalLahirCtrl.text.trim(),
        tinggiBadan: _tinggiBadanCtrl.text.trim(),
        bbPraHamil: _bbPraHamilCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil berhasil diperbarui'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Edit Profil',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text(
                'NIK tidak dapat diubah melalui aplikasi.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24.0),

              // Nama Ibu
              _buildField(
                controller: _namaIbuCtrl,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outline_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16.0),

              // Tanggal Lahir
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _buildField(
                    controller: _tanggalLahirCtrl,
                    label: 'Tanggal Lahir',
                    hint: 'YYYY-MM-DD',
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Tinggi Badan
              _buildField(
                controller: _tinggiBadanCtrl,
                label: 'Tinggi Badan (cm)',
                hint: 'Contoh: 160',
                icon: Icons.height_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16.0),

              // BB Pra Hamil
              _buildField(
                controller: _bbPraHamilCtrl,
                label: 'Berat Badan Pra Hamil (kg)',
                hint: 'Contoh: 55',
                icon: Icons.monitor_weight_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))],
              ),
              const SizedBox(height: 28.0),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size.fromHeight(52.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                      )
                    : Text('Simpan Perubahan', style: AppTypography.labelLarge.copyWith(color: AppColors.onPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20.0, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
    );
  }
}
