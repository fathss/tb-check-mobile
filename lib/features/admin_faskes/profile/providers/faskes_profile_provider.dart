import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/faskes_profile_model.dart';
import '../../../../features/auth/data/datasources/auth_storage.dart';

class FaskesProfileProvider with ChangeNotifier {
  FaskesProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;
  
  final AuthStorage _authStorage = AuthStorage();

  FaskesProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mengambil data saat halaman dibuka
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authStorage.getToken();

      // KEMBALI MENGGUNAKAN DEFAULT FASKES ID DARI DATABASE
      final url = '${AppConstants.baseUrl}/Faskes/${AppConstants.defaultFaskesId}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        }
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _profile = FaskesProfileModel.fromJson(json.decode(response.body));
      } else {
        _errorMessage = 'Gagal memuat profil faskes. (Kode: ${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mengirim data yang diubah ke C#
  Future<bool> updateProfile(Map<String, dynamic> updatedData) async {
    try {
      final token = await _authStorage.getToken();

      // KEMBALI MENGGUNAKAN DEFAULT FASKES ID
      final url = '${AppConstants.baseUrl}/Faskes/${AppConstants.defaultFaskesId}';
      
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        await fetchProfile(); // Segarkan data setelah update berhasil
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}