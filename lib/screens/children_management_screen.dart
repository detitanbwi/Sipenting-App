import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/api_service.dart';

class ChildrenManagementScreen extends StatefulWidget {
  const ChildrenManagementScreen({super.key});

  @override
  State<ChildrenManagementScreen> createState() => _ChildrenManagementScreenState();
}

class _ChildrenManagementScreenState extends State<ChildrenManagementScreen> {
  bool _isLoading = true;
  List<dynamic> _children = [];

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final childrenList = await ApiService.getBayi();
      setState(() {
        _children = childrenList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data anak: $e')),
      );
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

  Future<void> _deleteChild(String idBayi) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Anak'),
        content: const Text('Apakah Anda yakin ingin menghapus data anak ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        await ApiService.deleteBayi(idBayi);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data anak berhasil dihapus')),
        );
        _fetchChildren();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data anak: $e')),
        );
      }
    }
  }

  void _showAddChildSheet() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final dobController = TextEditingController();
    String gender = 'L';
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.0),
                  topRight: Radius.circular(28.0),
                ),
              ),
              padding: EdgeInsets.only(
                top: 24.0,
                left: 24.0,
                right: 24.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tambah Data Anak',
                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap Anak',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.child_care),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: dobController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? now,
                          firstDate: DateTime(now.year - 5),
                          lastDate: now,
                        );
                        if (picked != null) {
                          selectedDate = picked;
                          dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal lahir tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Jenis Kelamin',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Laki-laki'),
                            value: 'L',
                            groupValue: gender,
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  gender = val;
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Perempuan'),
                            value: 'P',
                            groupValue: gender,
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  gender = val;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await ApiService.storeBayi(
                              nama: nameController.text.trim(),
                              tanggalLahir: dobController.text,
                              kelamin: gender,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Data anak berhasil ditambahkan')),
                            );
                            _fetchChildren();
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menambahkan data anak: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Simpan Data',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
          'Daftar Anak',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchChildren,
          color: AppColors.primary,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 100.0),
                  children: [
                    Text(
                      'Kelola Data\nBuah Hati Anda',
                      style: AppTypography.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Tambahkan atau perbarui data balita untuk memantau tumbuh kembangnya dengan akurat.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    if (_children.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Belum ada data buah hati terdaftar.',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      )
                    else
                      ..._children.map((child) {
                        final String idBayi = child['id'].toString();
                        final String name = child['nama'] ?? '';
                        final String age = _formatAge(child['umur']);
                        final String genderVal = child['kelamin'] ?? 'L';
                        final String gender = genderVal == 'L' ? 'Laki-laki' : 'Perempuan';
                        
                        final String status;
                        final Color statusColor;
                        final int? statusStunting = child['status_stunting'];
                        
                        if (statusStunting == 1) {
                          status = 'Sangat Pendek';
                          statusColor = AppColors.error;
                        } else if (statusStunting == 2) {
                          status = 'Pendek (Stunting)';
                          statusColor = Colors.orange;
                        } else if (statusStunting == 3) {
                          status = 'Normal';
                          statusColor = const Color(0xFF4CAF50);
                        } else if (statusStunting == 4) {
                          status = 'Tinggi';
                          statusColor = Colors.blue;
                        } else {
                          status = 'Belum Cek';
                          statusColor = AppColors.outline;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildChildCard(
                            idBayi: idBayi,
                            name: name,
                            age: age,
                            gender: gender,
                            status: status,
                            statusColor: statusColor,
                          ),
                        );
                      }),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddChildSheet,
        backgroundColor: AppColors.primaryContainer,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: AppColors.onPrimaryContainer),
        label: Text(
          'Tambah Anak',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChildCard({
    required String idBayi,
    required String name,
    required String age,
    required String gender,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.03),
            blurRadius: 20.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Icon(
                  gender == 'Laki-laki' ? Icons.boy_rounded : Icons.girl_rounded,
                  color: AppColors.onSecondaryContainer,
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
                      gender,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteChild(idBayi);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8.0),
                        Text('Hapus'),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert_rounded),
                color: AppColors.surfaceContainerLowest,
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usia',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      age,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Stunting',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.health_and_safety_rounded, color: statusColor, size: 16.0),
                        const SizedBox(width: 4.0),
                        Text(
                          status,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
