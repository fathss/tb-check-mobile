import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/data/datasources/auth_storage.dart'; // Import Auth Storage

import '../datasources/user_profile_datasource.dart';
import '../../models/home_summary_model.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final datasource = ref.watch(userProfileDatasourceProvider);
  return UserProfileRepository(datasource);
});

class UserProfileRepository {
  final UserProfileDatasource _datasource;
  final AuthStorage _authStorage = AuthStorage(); // Panggil storage untuk token

  UserProfileRepository(this._datasource);

  Future<bool> hasProfile(String userId) async {
    return _datasource.hasProfile(userId);
  }

  Future<void> completeProfile({
    required String userId,
    required String fullName,
    required String nik,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    await _datasource.completeProfile(
      userId: userId,
      fullName: fullName,
      nik: nik,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
  }

  Future<HomeSummaryModel> getHomeSummary(String userId) async {
    return _datasource.getHomeSummary(userId);
  }

  // --- REVISI: FUNGSI GET PROFILE (DENGAN TOKEN JWT) ---
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final url = '${AppConstants.baseUrl}/Profile/$userId';
      final token = await _authStorage.getToken(); // Ambil Token

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token', // Serahkan Token ke C#
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("API Ditolak. Status Code: ${response.statusCode}");
        return {}; 
      }
    } catch (e) {
      print("Error Fetching Profile: $e");
      return {};
    }
  }

  // --- REVISI: FUNGSI UPDATE PROFILE (DENGAN TOKEN JWT) ---
  Future<bool> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      final url = '${AppConstants.baseUrl}/Profile/$userId';
      final token = await _authStorage.getToken(); // Ambil Token

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token', // Serahkan Token ke C#
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error Updating Profile: $e");
      return false;
    }
  }
  // Fungsi untuk mengganti kata sandi
  Future<bool> changePassword(String userId, String oldPassword, String newPassword) async {
    try {
      final url = '${AppConstants.baseUrl}/Profile/$userId/change-password';
      final token = await _authStorage.getToken();

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      // Status 200 berarti sukses, jika status 400 (Sandi lama salah) maka kembalikan false
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Gagal ganti sandi: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error Change Password: $e");
      return false;
    }
  }
}