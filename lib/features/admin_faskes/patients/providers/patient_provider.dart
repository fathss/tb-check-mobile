import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/patient_model.dart';

class PatientProvider with ChangeNotifier {
  List<PatientModel> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PatientModel> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Ganti localhost dengan 10.0.2.2 jika pakai Emulator Android
  final String baseUrl = 'http://192.168.1.11:5134/api/Patient'; 

  Future<void> fetchPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _patients = data.map((json) => PatientModel.fromJson(json)).toList();
      } else {
        _errorMessage = 'Gagal memuat data pasien: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPatient(Map<String, dynamic> patientData) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(patientData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPatients(); // Refresh data setelah berhasil nambah
        return true;
      } else {
        // Cek terminal/debug console VS Code untuk melihat alasan penolakan
        print('=== ERROR DARI BACKEND ===');
        print('Status Code: ${response.statusCode}');
        print('Pesan Error: ${response.body}');
        print('==========================');
        return false;
      }
    } catch (e) {
      print('=== EXCEPTION ===');
      print(e.toString());
      return false;
    }
  }
}