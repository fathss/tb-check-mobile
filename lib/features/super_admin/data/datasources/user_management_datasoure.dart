import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/network/api_client.dart'; // Sesuaikan path ApiClient Anda
import 'package:dio/dio.dart';

import '../models/user_detail_model.dart';
import '../models/user_model.dart';

final userManagementDatasourceProvider = Provider<UserManagementDatasource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return UserManagementDatasource(apiClient);
});

class UserManagementDatasource {
  final ApiClient _apiClient;

  UserManagementDatasource(this._apiClient);

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _apiClient.dio.get('/users');
      final payload = response.data;

      if (payload is List) {
        return payload
            .map<UserModel>(
              (user) => UserModel.fromJson(user as Map<String, dynamic>),
            )
            .toList();
      }

      if (payload is Map && payload['data'] is List) {
        return (payload['data'] as List)
            .map<UserModel>(
              (user) => UserModel.fromJson(user as Map<String, dynamic>),
            )
            .toList();
      }

      throw Exception('Unexpected response format when fetching users');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil data pengguna');
    } catch (e) {
      throw Exception('Terjadi kesalahan format data');
    }
  }

  Future<UserDetailModel> getUserById(String userId) async {
    try {
      final response = await _apiClient.dio.get('/users/$userId');
      final payload = response.data;

      if (payload is Map<String, dynamic>) {
        return UserDetailModel.fromJson(payload);
      }

      throw Exception('Unexpected response format when fetching user detail');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil detail pengguna');
    } catch (e) {
      throw Exception('Terjadi kesalahan format data detail pengguna');
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      await _apiClient.dio.post('/users/$userId/activate');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengaktifkan akun pengguna');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengaktifkan akun pengguna');
    }
  }

  Future<void> suspendUser(String userId) async {
    try {
      await _apiClient.dio.post('/users/$userId/suspend');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal menonaktifkan akun pengguna');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menonaktifkan akun pengguna');
    }
  }
}
