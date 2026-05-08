import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/super_admin/widgets/custom_button.dart';

class AddFaskesPage extends StatefulWidget {
  const AddFaskesPage({Key? key}) : super(key: key);

  @override
  State<AddFaskesPage> createState() => _AddFaskesPageState();
}

class _AddFaskesPageState extends State<AddFaskesPage> {
  String selectedKategori = 'Puskesmas'; // Default selection
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController alamatLengkapController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();

  @override
  void dispose() {
    namaController.dispose();
    lokasiController.dispose();
    alamatLengkapController.dispose();
    teleponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Faskes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Kategori Faskes Section
                    _buildKategoriSection(),
                    const SizedBox(height: 32),
                    // Form Fields
                    _buildFormField(
                      label: 'Nama Fasilitas Kesehatan',
                      hint: 'Masukkan nama resmi',
                      controller: namaController,
                    ),
                    const SizedBox(height: 20),
                    _buildLocationField(),
                    const SizedBox(height: 20),
                    _buildFormField(
                      label: 'Alamat Lengkap',
                      hint: 'Contoh: Jl. Keputih Sukolilo, Kec. Sukolilo',
                      controller: alamatLengkapController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _buildFormField(
                      label: 'Nomor Telepon Faskes',
                      hint: '(Kode Area) Nomor...',
                      controller: teleponController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  width: double.infinity,
                  label: 'Simpan Faskes',
                  icon: Icons.save,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process the form
                    }
                  },
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Faskes',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKategoriButton(
                'Puskesmas',
                selectedKategori == 'Puskesmas',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKategoriButton(
                'Rumah Sakit',
                selectedKategori == 'Rumah Sakit',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKategoriButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedKategori = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBg : AppColors.third,
          border: isActive
              ? Border.all(color: AppColors.primary, width: 0)
              : Border.all(color: Colors.transparent, width: 0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.third,
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.cardStroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.cardStroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Titik Lokasi / Alamat',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Handle location selection
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.third,
              border: Border.all(color: AppColors.cardStroke),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lokasiController.text.isEmpty
                        ? 'Pilih titik lokasi di Peta...'
                        : lokasiController.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: lokasiController.text.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
