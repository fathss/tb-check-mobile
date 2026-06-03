import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/patient_provider.dart';
import 'patient_form_page.dart';
import 'patient_detail_page.dart';
import 'package:tbcheck_app/features/admin_faskes/patients/pages/patient_form_page.dart';
import 'package:tbcheck_app/features/admin_faskes/patients/pages/assign_patient_page.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({Key? key}) : super(key: key);

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  String selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Abu-abu sangat muda (background)
      appBar: AppBar(
        title: const Text('Database Pasien', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F0FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.blue),
            ),
            onPressed: () {
              // TAMPILKAN POP-UP BOTTOM SHEET DI SINI
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Pilih Metode Pendaftaran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFFE9F0FF), child: Icon(Icons.search, color: Colors.blue)),
                          title: const Text("Tarik Pengguna Terdaftar", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text("Cari berdasarkan NIK pengguna aplikasi"),
                          onTap: () {
                            Navigator.pop(context); // Tutup pop-up
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignPatientPage()));
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFFFDE8E8), child: Icon(Icons.edit_document, color: Colors.red)),
                          title: const Text("Input Manual", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text("Daftarkan pasien yang belum memiliki akun"),
                          onTap: () {
                            Navigator.pop(context); // Tutup pop-up
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientFormPage()));
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (value) {
                // Langsung tembak API setiap kali user mengetik
                context.read<PatientProvider>().fetchPatients(
                  filterStatus: selectedFilter, // Tetap pertahankan filter yang sedang aktif
                  searchQuery: value,
                );
              },
              decoration: InputDecoration(
                hintText: 'Cari nama pasien di wilayah ini...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF1F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // 2. FILTER CHIPS
          Container(
            height: 50,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Semua'),
                _buildFilterChip('Aktif Dirawat'),
                _buildFilterChip('Drop-out'),
                _buildFilterChip('Sembuh'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 3. LIST PASIEN
          Expanded(
            child: Consumer<PatientProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                if (provider.patients.isEmpty) return const Center(child: Text("Belum ada data"));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.patients.length,
                  itemBuilder: (context, index) {
                    final patient = provider.patients[index];
                    return _buildPatientCard(patient);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Bantuan: Filter Chip
  Widget _buildFilterChip(String label) {
    bool isActive = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
        selected: isActive,
        onSelected: (val) {
          setState(() => selectedFilter = label);
          // Panggil API ulang dengan filter status yang baru diklik
          context.read<PatientProvider>().fetchPatients(filterStatus: label);
        },
        selectedColor: const Color(0xFF1060EF),
        backgroundColor: Colors.white,
        shape: StadiumBorder(side: BorderSide(color: isActive ? Colors.transparent : Colors.blue.shade100)),
        showCheckmark: false,
      ),
    );
  }

  // Widget Bantuan: Patient Card (Sesuai Gambar)
  Widget _buildPatientCard(dynamic patient) {
    // Mapping warna status
    Color statusColor;
    String statusText = patient.displayStatus; // Memanggil logika dari PatientModel
    
    if (statusText == 'Aktif Dirawat') {
      statusColor = const Color(0xFF1060EF); // Biru
    } else if (statusText == 'Sembuh') {
      statusColor = Colors.green; // Hijau
    } else if (statusText == 'Drop-out') {
      statusColor = Colors.red.shade400; // Merah untuk peringatan Drop-out
    } else {
      statusColor = Colors.grey;
    }

    // --- BAGIAN YANG DIRUBAH (DITAMBAH INKWELL) ---
    return InkWell(
      onTap: () {
        // Navigasi ke halaman detail saat Card diklik
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDetailPage(patient: patient),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16), // Agar efek klik melengkung mengikuti kotak
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar dengan Inisial
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFF1F4F8),
                  child: Text(patient.fullName[0].toUpperCase(), 
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                // Nama dan ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.fullName, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('ID: #PT-${patient.nik.substring(patient.nik.length - 4)}', 
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  ),
                ),
                // Badge Status (Kanan Atas)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Text(statusText, 
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 12),
            // Footer Tanggal
            Text(
              'Terdiagnosis: ${DateFormat('d MMM yyyy', 'id_ID').format(patient.diagnosisDate)}',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}