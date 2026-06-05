import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; 
import 'package:http/http.dart' as http;
import 'package:tbcheck_app/core/constants/app_constants.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';

class LocationTrackerService {
  static Future<void> trackAndSend({required String patientId, required String activityName}) async {
    try {
      final authStorage = AuthStorage();
      final token = await authStorage.getToken();
      if (token == null) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      }
      
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // --- MENGUBAH KOORDINAT JADI NAMA JALAN ---
      String addressText = "Lokasi terdeteksi";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          // Hasil: "Jl. Raya ITS, Sukolilo, Surabaya"
          addressText = "${place.street}, ${place.subLocality}, ${place.locality}";
          // Bersihkan koma yang berlebih jika ada data kosong
          addressText = addressText.replaceAll(', ,', ',').replaceAll(' ,', '').trim();
        }
      } catch (e) {
        debugPrint("Geocoding gagal: $e");
      }

      String finalActivityDesc = "$activityName\n📍 $addressText";

      final url = '${AppConstants.baseUrl}/Patient/$patientId/locations';
      await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "activityDescription": finalActivityDesc 
        }),
      );
    } catch (e) {
      debugPrint("Tracker Error: $e");
    }
  }
}