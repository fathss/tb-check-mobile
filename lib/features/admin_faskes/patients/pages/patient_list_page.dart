import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/patient_provider.dart';
import 'patient_form_page.dart';

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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE9F0FF), // Biru sangat muda
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF1060EF)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientFormPage())),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
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
        onSelected: (val) => setState(() => selectedFilter = label),
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
    String statusText = patient.status;
    
    if (patient.status.toLowerCase().contains('aktif')) {
      statusColor = const Color(0xFF1060EF);
      statusText = "Aktif Dirawat";
    } else if (patient.status.toLowerCase().contains('sembuh')) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey;
    }

    return Container(
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
    );
  }
}