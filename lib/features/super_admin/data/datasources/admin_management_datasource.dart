import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/network/api_client.dart';
import 'package:dio/dio.dart';

import '../models/create_admin_model.dart';

final adminManagementDatasourceProvider = Provider<AdminManagementDatasource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminManagementDatasource(apiClient);
});

class AdminManagementDatasource {
  final ApiClient _apiClient;

  AdminManagementDatasource(this._apiClient);

  Future<void> createAdmin(CreateAdminModel createAdminModel) async {
    try {
      await _apiClient.dio.post(
        '/admins/create',
        data: createAdminModel.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal membuat akun admin');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat membuat akun admin');
    }
  }

  Future<void> resetPassword(String adminId) async {
    try {
      await _apiClient.dio.post('/admins/$adminId/reset-password');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mereset password admin');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mereset password admin');
    }
  }

  Future<void> activateAdmin(String adminId) async {
    try {
      await _apiClient.dio.put('/admins/$adminId/activate');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengaktifkan akun admin');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengaktifkan akun admin');
    }
  }

  Future<void> suspendAdmin(String adminId) async {
    try {
      await _apiClient.dio.put('/admins/$adminId/suspend');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal menonaktifkan akun admin');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menonaktifkan akun admin');
    }
  }

  Future<void> deleteAdmin(String adminId) async {
    try {
      await _apiClient.dio.delete('/admins/$adminId');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal menghapus akun admin');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghapus akun admin');
    }
  }

  Future<Map<String, dynamic>> getAdminById(String adminId) async {
    try {
      // Use admin-specific endpoint now available on the backend.
      final response = await _apiClient.dio.get('/admins/$adminId');
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return Map<String, dynamic>.from(response.data ?? {});
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal memuat detail admin');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat detail admin');
    }
  }
}
