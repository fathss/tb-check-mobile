import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart'; 
import '../models/patient_model.dart';
import '../../map_tracking/models/location_history_model.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';

class PatientProvider with ChangeNotifier {
  final AuthStorage _authStorage = AuthStorage();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<PatientModel> _patients = [];
  List<PatientModel> get patients => _patients;

  List<LocationHistoryModel> _locationHistories = [];
  List<LocationHistoryModel> get locationHistories => _locationHistories;

    
  double _complianceRate = 0.0;
  List<dynamic> _medicationLogs = [];
  
  double get complianceRate => _complianceRate;
  List<dynamic> get medicationLogs => _medicationLogs;

  final String _patientUrl = '${AppConstants.baseUrl}/Patient'; 

  Future<void> fetchPatients({String filterStatus = 'Semua', String searchQuery = ''}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authStorage.getToken(); 
      // MENGAMBIL ID SECARA DINAMIS
      final dynamicFaskesId = await _authStorage.getFaskesProfileId();

      if (dynamicFaskesId == null || dynamicFaskesId.isEmpty) {
        _errorMessage = 'Akun ini belum tertaut dengan Faskes.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // GUNAKAN ID DINAMIS DI URL
      String url = '$_patientUrl?faskesId=$dynamicFaskesId';
      
      if (filterStatus != 'Semua') {
        url += '&status=${Uri.encodeComponent(filterStatus)}';
      }
      if (searchQuery.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(searchQuery)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        }
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _patients = data.map((json) => PatientModel.fromJson(json)).toList();
      } else {
        _errorMessage = 'Gagal memuat data pasien';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan: $e';
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

  Future<void> fetchLocationHistory(String patientId, DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      final url = '${AppConstants.baseUrl}/Patient/$patientId/locations?date=$formattedDate';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _locationHistories = data.map((json) => LocationHistoryModel.fromJson(json)).toList();
      } else {
        _errorMessage = 'Gagal memuat riwayat lokasi';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> findUserByNik(String nik) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authStorage.getToken();
      final url = '${AppConstants.baseUrl}/Patient/find-user/$nik';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      } else {
        final resBody = jsonDecode(response.body);
        _errorMessage = resBody['message'] ?? "Pengguna tidak ditemukan";
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Terjadi kesalahan jaringan: $e";
      notifyListeners();
      return null;
    }
  }

  Future<bool> createPatient({
    required String nik,
    required String fullName,
    required String tbType,
    required String diagnosisDate,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = await _authStorage.getUserId();
      final token = await _authStorage.getToken();
      // MENGAMBIL ID FASKES DINAMIS
      final dynamicFaskesId = await _authStorage.getFaskesProfileId();

      if (userId == null || token == null || dynamicFaskesId == null) {
        _errorMessage = "Sesi/Faskes tidak valid. Silakan login kembali.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final url = '${AppConstants.baseUrl}/Patient';
      
      final Map<String, dynamic> body = {
        "nik": nik,
        "fullName": fullName,
        "tbType": tbType,
        "diagnosisDate": diagnosisDate, 
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        // GUNAKAN ID DINAMIS SAAT INSERT
        "faskesProfileId": dynamicFaskesId 
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPatients();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final resBody = jsonDecode(response.body);
        _errorMessage = resBody['message'] ?? "Gagal menambahkan pasien";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Terjadi kesalahan jaringan: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePatient(String patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authStorage.getToken();
      final url = '${AppConstants.baseUrl}/Patient/$patientId';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await fetchPatients(); 
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final resBody = jsonDecode(response.body);
        _errorMessage = resBody['message'] ?? "Gagal menghapus pasien";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Terjadi kesalahan jaringan: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========================================================
  // FUNGSI PENGAMBILAN LOG KEPATUHAN MINUM OBAT
  // ========================================================

  Future<void> fetchMedicationLogs(String patientId, DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authStorage.getToken();
      
      // Format tanggal menjadi yyyy-MM-dd
      String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      final url = '${AppConstants.baseUrl}/Patient/$patientId/medication-logs?date=$formattedDate';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // C# mereturn JSON { "complianceRate": 0.92, "logs": [...] }
        _complianceRate = (data['complianceRate'] ?? 0.0).toDouble();
        _medicationLogs = data['logs'] ?? [];
      } else {
        _errorMessage = 'Gagal memuat riwayat obat';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}