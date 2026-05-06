import 'package:flutter/material.dart';
import '../widgets/custom_text_field_widget.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Institusi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.local_hospital, size: 40, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 32),
            
            const CustomTextFieldWidget(label: 'Nama Faskes', placeholder: 'Puskesmas Perak Timur'),
            const SizedBox(height: 16),
            
            const CustomTextFieldWidget(label: 'Tipe Faskes', placeholder: 'Puskesmas Tingkat Pertama'),
            const SizedBox(height: 16),
            
            const CustomTextFieldWidget(label: 'Wilayah Jangkauan', placeholder: 'Kec. Pabean Cantian, Surabaya'),
            const SizedBox(height: 16),
            
            const CustomTextFieldWidget(label: 'Jam Operasional Layanan TBC', placeholder: 'Senin - Jumat, 08:00 - 14:00 WIB'),
            const SizedBox(height: 16),
            
            const CustomTextFieldWidget(label: 'Nomor Darurat / Call Center', placeholder: '031-1234567'),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                },
                child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}