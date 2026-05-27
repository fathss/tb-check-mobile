import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';

class PatientFormPage extends StatefulWidget {
  const PatientFormPage({Key? key}) : super(key: key);

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  String _selectedTBType = 'Paru';
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() { _selectedDate = picked; });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menyimpan data...')),
      );

      final newPatientData = {
        "nik": _nikController.text,
        "fullName": _nameController.text,
        "tbType": _selectedTBType,
        "diagnosisDate": _selectedDate.toUtc().toIso8601String(),
        "latitude": -7.2144, // Default sementara
        "longitude": 112.7355, // Default sementara
        "address": _addressController.text,
        "faskesProfileId": "65a0f259-fe09-4dd6-b241-461fa5423991" // Gunakan ID asli yang sudah valid
      };

      final success = await context.read<PatientProvider>().createPatient(newPatientData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        Navigator.pop(context); // Kembali ke halaman list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Pasien', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nikController,
                decoration: const InputDecoration(labelText: 'NIK', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTBType,
                decoration: const InputDecoration(labelText: 'Tipe TBC', border: OutlineInputBorder()),
                items: ['Paru', 'Ekstra Paru'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedTBType = val!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal Diagnosis'),
                subtitle: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: _submitForm,
                  child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}