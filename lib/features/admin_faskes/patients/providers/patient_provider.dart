import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart'; // Sesuaikan path import jika perlu
import '../models/patient_model.dart';

class PatientProvider with ChangeNotifier {
  List<PatientModel> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PatientModel> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Endpoint khusus untuk Patient
  final String _patientUrl = '${AppConstants.baseUrl}/Patient'; 

  Future<void> fetchPatients({String filterStatus = 'Semua'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String url = '$_patientUrl?faskesId=${AppConstants.defaultFaskesId}';
      if (filterStatus != 'Semua') {
        url += '&status=${Uri.encodeComponent(filterStatus)}';
      }

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _patients = data.map((json) => PatientModel.fromJson(json)).toList();
      } else {
        _errorMessage = 'Gagal memuat data pasien';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePatientStatus(String patientId, String newStatus, String notes) async {
    try {
      final response = await http.put(
        Uri.parse('$_patientUrl/$patientId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "newStatus": newStatus,
          "medicalNotes": notes
        }),
      );

      if (response.statusCode == 200) {
        await fetchPatients(); 
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createPatient(Map<String, dynamic> patientData) async {
    try {
      final response = await http.post(
        Uri.parse(_patientUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(patientData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPatients(); 
        return true;
      } else {
        print('Error dari Backend: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }
}