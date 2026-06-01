import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../models/today_schedule_model.dart';

class MedicineProvider with ChangeNotifier {
  List<TodayScheduleModel> _todaySchedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TodayScheduleModel> get todaySchedules => _todaySchedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- 1. VARIABEL PROGRESS DIJADIKAN DINAMIS ---
  int _totalDosis = 180; 
  int _dosisSelesai = 0; 

  int get totalDosis => _totalDosis;
  int get dosisSelesai => _dosisSelesai;

  // --- VARIABEL UNTUK DAFTAR SEMUA OBAT ---
  List<dynamic> _allMedicines = [];
  List<dynamic> get allMedicines => _allMedicines;
  
  // Menggunakan .clamp(0.0, 1.0) agar jika ada error data, bar tidak melebar keluar batas (maksimal 100%)
  double get progressPercentage => _totalDosis > 0 ? (_dosisSelesai / _totalDosis).clamp(0.0, 1.0) : 0.0;

    // --- VARIABEL UNTUK JADWAL KALENDER ---
  List<dynamic> _selectedDateSchedules = [];
  List<dynamic> get selectedDateSchedules => _selectedDateSchedules;
  bool _isCalendarLoading = false;
  bool get isCalendarLoading => _isCalendarLoading;


  // --- FUNGSI FETCH JADWAL HARI INI (REVISI PROGRESS HARIAN) ---
  Future<void> fetchTodaySchedule(String patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Tarik Jadwal Hari Ini
      final scheduleUrl = '${AppConstants.baseUrl}/MedicineSchedules/today/$patientId';
      final scheduleResponse = await http.get(Uri.parse(scheduleUrl)).timeout(const Duration(seconds: 15));

      if (scheduleResponse.statusCode == 200) {
        final List<dynamic> data = json.decode(scheduleResponse.body);
        _todaySchedules = data.map((json) => TodayScheduleModel.fromJson(json)).toList();

        // LOGIKA BARU: Hitung progress murni dari jadwal HARI INI saja
        _totalDosis = _todaySchedules.length;
        
        // Hitung berapa obat yang isDone == true
        _dosisSelesai = _todaySchedules.where((schedule) => schedule.isDone).length;

      } else {
        _errorMessage = 'Gagal memuat jadwal obat';
        _totalDosis = 0;
        _dosisSelesai = 0;
      }
      
      // Catatan: Pemanggilan API progress C# sudah dihapus karena kita hitung secara lokal.

    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan';
      _totalDosis = 0;
      _dosisSelesai = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 3. FUNGSI TARIK SEMUA OBAT ---
  Future<void> fetchAllMedicines(String patientId) async {
    try {
      final url = '${AppConstants.baseUrl}/Medicines?patientId=$patientId';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allMedicines = data;
        notifyListeners(); // Refresh UI
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
      // Format tanggal menjadi YYYY-MM-DD untuk C#
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

  // Fungsi untuk menekan tombol konfirmasi minum obat
  Future<bool> confirmConsume(String scheduleId, String patientId) async {
    try {
      final url = '${AppConstants.baseUrl}/MedicineSchedules/confirm/$scheduleId';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Karena fetchTodaySchedule memanggil API Jadwal & API Progress sekaligus,
        // UI (centang hijau & progress bar) akan otomatis ter-update di sini!
        await fetchTodaySchedule(patientId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Fungsi untuk Menambahkan Obat Baru
  Future<bool> addMedicine({
    required String patientId,
    required String name,
    required String function,
    required String dosage,
    required int stock,
    required int imageIndex,
    required String condition,
    required List<bool> activeDays,
    required List<String> consumeTimes, // Harus format "HH:mm" (24 jam)
  }) async {
    try {
      final url = '${AppConstants.baseUrl}/Medicines';
      
      // Susun Payload sesuai dengan model Entity Framework yang lama
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
        await fetchAllMedicines(patientId); // <--- BARIS INI YANG DITAMBAHKAN
        return true;
      }
      return false;
    } catch (e) {
      print("EXCEPTION ADD MEDICINE: $e");
      return false;
    }
  }
}