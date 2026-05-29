import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/network/api_client.dart';

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthDatasource(apiClient);
});

class AuthDatasource {
  final ApiClient _apiClient;

  AuthDatasource(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return Map<String, dynamic>.from(response.data ?? {});
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Gagal melakukan login'));
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem saat login');
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      await _apiClient.dio.post(
        '/auth/register',
        data: {'username': username, 'email': email, 'password': password},
      );
    } on DioException catch (e) {
      throw Exception(
        _extractErrorMessage(e, 'Gagal melakukan pendaftaran akun'),
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem saat pendaftaran');
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
