import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart'; 
import '../models/patient_model.dart';
import '../../map_tracking/models/location_history_model.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';

class PatientProvider with ChangeNotifier {
  // DEFINISIKAN AUTH STORAGE DI SINI UNTUK MENGATASI ERROR UNDEFINED
  final AuthStorage _authStorage = AuthStorage();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- KEMBALIKAN VARIABEL PATIENTS DI SINI ---
  List<PatientModel> _patients = [];
  List<PatientModel> get patients => _patients;
  // --------------------------------------------

  // --- TAMBAHAN UNTUK RIWAYAT LOKASI ---
  List<LocationHistoryModel> _locationHistories = [];
  List<LocationHistoryModel> get locationHistories => _locationHistories;

  // Endpoint khusus untuk Patient
  final String _patientUrl = '${AppConstants.baseUrl}/Patient'; 

  Future<void> fetchPatients({String filterStatus = 'Semua', String searchQuery = ''}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authStorage.getToken(); // Tetap butuh token untuk keamanan

      // KEMBALIKAN KE DEFAULT FASKES ID
      String url = '$_patientUrl?faskesId=${AppConstants.defaultFaskesId}';
      
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
      // Format DateTime menjadi string yyyy-MM-dd agar cocok dengan backend C#
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

  // ========================================================
  // 2. FUNGSI PENCARIAN USER UNTUK ASSIGN (BARU)
  // ========================================================
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

  // ========================================================
  // 3. FUNGSI CREATE PATIENT 
  // ========================================================
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

      if (userId == null || token == null) {
        _errorMessage = "Sesi tidak valid. Silakan login kembali.";
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
        "faskesProfileId": AppConstants.defaultFaskesId 
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
        // Otomatis refresh daftar pasien setelah berhasil input/assign
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

  // ========================================================
  // 4. FUNGSI HAPUS PASIEN
  // ========================================================
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
        // Jika berhasil dihapus, perbarui daftar pasien agar yang dihapus hilang dari layar
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
}