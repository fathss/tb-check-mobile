import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../models/today_schedule_model.dart';
// --- IMPORT BARU UNTUK ADMIN SURVEILLANCE ---
import '../../auth/data/datasources/auth_storage.dart';
import '../models/medication_log_model.dart'; 

class MedicineProvider with ChangeNotifier {
  // ==========================================
  // STATE UNTUK SISI PASIEN
  // ==========================================
  List<TodayScheduleModel> _todaySchedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TodayScheduleModel> get todaySchedules => _todaySchedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int _totalDosis = 180; 
  int _dosisSelesai = 0; 

  int get totalDosis => _totalDosis;
  int get dosisSelesai => _dosisSelesai;

  List<dynamic> _allMedicines = [];
  List<dynamic> get allMedicines => _allMedicines;
  
  double get progressPercentage => _totalDosis > 0 ? (_dosisSelesai / _totalDosis).clamp(0.0, 1.0) : 0.0;

  List<dynamic> _selectedDateSchedules = [];
  List<dynamic> get selectedDateSchedules => _selectedDateSchedules;
  bool _isCalendarLoading = false;
  bool get isCalendarLoading => _isCalendarLoading;

  // ==========================================
  // STATE BARU UNTUK SISI ADMIN (SURVEILLANCE)
  // ==========================================
  List<MedicationLogModel> _dailyLogs = [];
  double _complianceRate = 0.0;

  List<MedicationLogModel> get dailyLogs => _dailyLogs;
  double get complianceRate => _complianceRate;


  // ==========================================
  // FUNGSI SISI ADMIN (BARU)
  // ==========================================
  Future<void> fetchMedicationLogs(String patientId, DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    
    // Format tanggal ke YYYY-MM-DD
    final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    notifyListeners();

    try {
      final authStorage = AuthStorage();
      final token = await authStorage.getToken();

      final url = '${AppConstants.baseUrl}/Patient/$patientId/medication-logs?date=$dateString';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        }
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _complianceRate = (data['complianceRate'] ?? 0).toDouble();
        
        final List<dynamic> logsJson = data['logs'] ?? [];
        _dailyLogs = logsJson.map((json) => MedicationLogModel.fromJson(json)).toList();
      } else {
        _errorMessage = 'Gagal memuat data kepatuhan obat.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // ==========================================
  // FUNGSI SISI PASIEN (LAMA - TIDAK DIUBAH)
  // ==========================================
  
  // --- FUNGSI FETCH JADWAL HARI INI ---
  Future<void> fetchTodaySchedule(String patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final scheduleUrl = '${AppConstants.baseUrl}/MedicineSchedules/today/$patientId';
      final scheduleResponse = await http.get(Uri.parse(scheduleUrl)).timeout(const Duration(seconds: 15));

      if (scheduleResponse.statusCode == 200) {
        final List<dynamic> data = json.decode(scheduleResponse.body);
        _todaySchedules = data.map((json) => TodayScheduleModel.fromJson(json)).toList();

        _totalDosis = _todaySchedules.length;
        _dosisSelesai = _todaySchedules.where((schedule) => schedule.isDone).length;
      } else {
        _errorMessage = 'Gagal memuat jadwal obat';
        _totalDosis = 0;
        _dosisSelesai = 0;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan';
      _totalDosis = 0;
      _dosisSelesai = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FUNGSI TARIK SEMUA OBAT ---
  Future<void> fetchAllMedicines(String patientId) async {
    try {
      final url = '${AppConstants.baseUrl}/Medicines?patientId=$patientId';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allMedicines = data;
        notifyListeners(); 
      }
    } catch (e) {
      print("EXCEPTION FETCH ALL MEDICINES: $e");
    }
  }

  // --- FUNGSI TARIK JADWAL BERDASARKAN TANGGAL ---
  Future<void> fetchScheduleByDate(String patientId, DateTime date) async {
    _isCalendarLoading = true;
    notifyListeners();

    try {
      String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      final url = '${AppConstants.baseUrl}/MedicineSchedules/date/$patientId?date=$formattedDate';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _selectedDateSchedules = json.decode(response.body);
      } else {
        _selectedDateSchedules = [];
      }
    } catch (e) {
      print("EXCEPTION FETCH CALENDAR: $e");
      _selectedDateSchedules = [];
    } finally {
      _isCalendarLoading = false;
      notifyListeners();
    }
  }

  // --- Fungsi untuk menekan tombol konfirmasi minum obat ---
  Future<bool> confirmConsume(String scheduleId, String patientId) async {
    try {
      final url = '${AppConstants.baseUrl}/MedicineSchedules/confirm/$scheduleId';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await fetchTodaySchedule(patientId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- Fungsi untuk Menambahkan Obat Baru ---
  Future<bool> addMedicine({
    required String patientId,
    required String name,
    required String function,
    required String dosage,
    required int stock,
    required int imageIndex,
    required String condition,
    required List<bool> activeDays,
    required List<String> consumeTimes, 
  }) async {
    try {
      final url = '${AppConstants.baseUrl}/Medicines';
      
      Map<String, dynamic> payload = {
        "PatientId": patientId,
        "Name": name,
        "Function": function,
        "Dosage": dosage,
        "Stock": stock,
        "SelectedImageIndex": imageIndex,
        "ConsumeCondition": condition,
        "ActiveDaysJson": jsonEncode(activeDays),
        "SchedulesJson": jsonEncode(consumeTimes),
        "IsCompleted": false,
        "Schedules": [],
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchTodaySchedule(patientId);
        await fetchAllMedicines(patientId); 
        return true;
      }
      return false;
    } catch (e) {
      print("EXCEPTION ADD MEDICINE: $e");
      return false;
    }
  }

  // ==========================================
  // FUNGSI UNTUK MEMBERSIHKAN DATA SAAT LOGOUT
  // ==========================================
  void clearData() {
    _todaySchedules = [];
    _allMedicines = [];
    _selectedDateSchedules = [];
    _dailyLogs = [];
    _dosisSelesai = 0;
    _complianceRate = 0.0;
    _errorMessage = null;
    notifyListeners();
  }
}