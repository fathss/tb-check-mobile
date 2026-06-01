import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tbcheck_app/core/network/api_client.dart';
import 'package:tbcheck_app/features/user_profile/models/home_summary_model.dart';

final userProfileDatasourceProvider = Provider<UserProfileDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserProfileDatasource(apiClient);
});

class UserProfileDatasource {
  final ApiClient _apiClient;

  UserProfileDatasource(this._apiClient);

  Future<bool> hasProfile(String userId) async {
    try {
      await _apiClient.dio.get('/profile/$userId');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
      throw Exception(
        _extractErrorMessage(e, 'Gagal mengecek profil pengguna'),
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem saat mengecek profil');
    }
  }

  Future<void> completeProfile({
    required String userId,
    required String fullName,
    required String nik,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    try {
      await _apiClient.dio.post(
        '/profile/$userId/complete-profile',
        data: {
          'userId': userId,
          'fullName': fullName,
          'nik': nik,
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'gender': gender,
        },
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Gagal melengkapi profil'));
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem saat melengkapi profil');
    }
  }

  Future<HomeSummaryModel> getHomeSummary(String userId) async {
    try {
      final response = await _apiClient.dio.get('/profile/$userId/home-summary');
      return HomeSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Gagal mengambil data beranda'));
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem saat memuat beranda');
    }
  }

  String _extractErrorMessage(DioException error, String fallbackMessage) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } else if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }

    return error.message ?? fallbackMessage;
  }
}
