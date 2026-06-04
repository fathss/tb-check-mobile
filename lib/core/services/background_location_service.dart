import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tbcheck_app/core/constants/app_constants.dart';

// Nama Task yang akan dipanggil oleh Workmanager
const fetchBackgroundLocationTask = "fetchBackgroundLocationTask";

// ============================================================================
// TOP-LEVEL FUNCTION: Fungsi ini berjalan di luar memori utama aplikasi.
// DILARANG memanggil Riverpod (ref.read), UI context, atau hal lain di sini.
// ============================================================================
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Native Background Task: Memulai tugas '$task'");
    
    if (task == fetchBackgroundLocationTask) {
      try {
        // 1. Inisialisasi Storage karena kita tidak bisa pakai Provider di sini
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'jwt_token');
        final userId = await storage.read(key: 'user_id');

        if (token == null || userId == null) {
          debugPrint("Background Task: Token atau User ID tidak ditemukan.");
          return Future.value(true); // Return true agar Android tidak mencoba mengulang terus
        }

        // 2. Ambil ID Pasien dari Endpoint Profil
        // (Karena kita tidak bisa memanggil homeSummaryProvider di background)
        final profileUrl = '${AppConstants.baseUrl}/UserProfile/$userId/home-summary';
        final profileRes = await http.get(
          Uri.parse(profileUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (profileRes.statusCode != 200) {
          debugPrint("Background Task: Gagal mengambil profil pasien.");
          return Future.value(true);
        }

        final profileData = jsonDecode(profileRes.body);
        final patientId = profileData['patientId'];

        if (patientId == null) {
          debugPrint("Background Task: User bukan pasien aktif.");
          return Future.value(true);
        }

        // 3. Dapatkan Koordinat Saat Ini
        // Pastikan kita sudah dapat izin sebelumnya saat aplikasi dibuka.
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          debugPrint("Background Task: Izin lokasi ditolak.");
          return Future.value(true);
        }

        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        // 4. Kirim ke Database C#
        final locationUrl = '${AppConstants.baseUrl}/Patient/$patientId/locations';
        final response = await http.post(
          Uri.parse(locationUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "latitude": position.latitude,
            "longitude": position.longitude,
            "activityDescription": "Update lokasi otomatis (Background)"
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint("Background Task: Lokasi berhasil dikirim!");
        } else {
          debugPrint("Background Task: Gagal mengirim lokasi. Kode: ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("Background Task: Terjadi kesalahan -> $e");
        // Return true agar tidak dianggap gagal oleh OS Android
        return Future.value(true);
      }
    }
    
    return Future.value(true);
  });
}