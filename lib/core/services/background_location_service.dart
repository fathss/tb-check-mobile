import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'package:tbcheck_app/core/constants/app_constants.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart'; // Sesuaikan path jika perlu

// Nama unik untuk tugas background kita
const String fetchBackgroundLocationTask = "fetchBackgroundLocationTask";

// FUNGSI INI HARUS ADA DI LUAR CLASS (Top-level function)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Cek izin lokasi terlebih dahulu
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return Future.value(false); // Berhenti jika tidak ada izin
      }

      // 2. Ambil lokasi GPS saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Ambil ID Pasien (User) dan Token dari Storage
      final authStorage = AuthStorage();
      final patientId = await authStorage.getUserId();
      final token = await authStorage.getToken();

      if (patientId == null || token == null) {
        return Future.value(false); // Berhenti jika user belum login
      }

      // 4. Kirim ke Backend C#
      final url = '${AppConstants.baseUrl}/Patient/$patientId/locations';
      final body = {
        "latitude": position.latitude,
        "longitude": position.longitude,
        "activityDescription": "Otomatis dari Background (1 Jam)"
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("BGC_SUCCESS: Lokasi latar belakang berhasil dikirim!");
        return Future.value(true);
      } else {
        print("BGC_ERROR: Gagal mengirim lokasi - ${response.body}");
        return Future.value(false);
      }
    } catch (err) {
      print("BGC_FATAL: $err");
      return Future.value(false);
    }
  });
}