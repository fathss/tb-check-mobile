import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/app_snackbar.dart';
import 'package:tbcheck_app/core/widgets/primary_button.dart';
import 'package:tbcheck_app/features/admin_faskes/patients/providers/patient_provider.dart';

class AssignPatientPage extends StatefulWidget {
  const AssignPatientPage({super.key});

  @override
  State<AssignPatientPage> createState() => _AssignPatientPageState();
}

class _AssignPatientPageState extends State<AssignPatientPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _foundUser;
  
  String _selectedTBType = 'Paru';
  final List<String> _tbTypes = ['Paru', 'Ekstra Paru', 'MDR'];
  DateTime _selectedDate = DateTime.now();

  void _searchUser() async {
    if (_searchController.text.trim().isEmpty) return;
    
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();

    final provider = context.read<PatientProvider>();
    final result = await provider.findUserByNik(_searchController.text.trim());

    if (result != null) {
      setState(() => _foundUser = result);
    } else {
      setState(() => _foundUser = null);
      if (mounted) AppSnackbar.showError(context, provider.errorMessage ?? "Tidak ditemukan");
    }
  }

  void _assignPatient() async {
    if (_foundUser == null) return;
    
    final provider = context.read<PatientProvider>();
    String formattedDate = _selectedDate.toUtc().toIso8601String();

    bool success = await provider.createPatient(
      nik: _foundUser!['nik'],
      fullName: _foundUser!['fullName'],
      tbType: _selectedTBType,
      diagnosisDate: formattedDate,
      latitude: 0, // Bypass karena lokasi ditangani HP pasien nantinya
      longitude: 0,
      address: "Alamat didapatkan dari profil pengguna", 
    );

    if (success && mounted) {
      AppSnackbar.showSuccess(context, "Pasien berhasil di-assign!");
      Navigator.pop(context); // Tutup halaman
    } else if (mounted) {
      AppSnackbar.showError(context, provider.errorMessage ?? "Gagal assign pasien");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PatientProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text("Tarik Pengguna Terdaftar", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Kotak Pencarian
            const Text("Cari berdasarkan NIK", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: InputBorder.none, hintText: "Masukkan NIK Pengguna..."),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: isLoading ? null : _searchUser,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                    child: isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.search, color: Colors.white),
                  ),
                )
              ],
            ),

            const SizedBox(height: 32),

            // 2. Hasil Pencarian & Form Tambahan
            if (_foundUser != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pengguna Ditemukan:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(_foundUser!['fullName'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text("NIK: ${_foundUser!['nik']}", style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text("Tipe TBC", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTBType,
                    isExpanded: true,
                    items: _tbTypes.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                    onChanged: (newValue) => setState(() => _selectedTBType = newValue!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              const Text("Tanggal Diagnosis", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: const TextStyle(fontSize: 16)),
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              PrimaryButton(text: "Jadikan Pasien", onPressed: _assignPatient),
            ]
          ],
        ),
      ),
    );
  }
}