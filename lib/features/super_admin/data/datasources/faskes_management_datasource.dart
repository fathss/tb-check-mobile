import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/network/api_client.dart'; // Sesuaikan path ApiClient Anda
import 'package:dio/dio.dart';

import '../models/faskes_model.dart';
import '../models/faskes_detail_model.dart';
import '../models/faskes_upsert_request.dart';

final faskesManagementDatasourceProvider = Provider<FaskesManagementDatasource>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return FaskesManagementDatasource(apiClient);
  },
);

class FaskesManagementDatasource {
  final ApiClient _apiClient;

  FaskesManagementDatasource(this._apiClient);

  Future<List<FaskesModel>> getAllFaskes() async {
    try {
      final response = await _apiClient.dio.get('/faskes');
      final payload = response.data;

      if (payload is List) {
        return payload
            .map<FaskesModel>(
              (faskes) => FaskesModel.fromJson(faskes as Map<String, dynamic>),
            )
            .toList();
      }

      if (payload is Map && payload['data'] is List) {
        return (payload['data'] as List)
            .map<FaskesModel>(
              (user) => FaskesModel.fromJson(user as Map<String, dynamic>),
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

  Future<FaskesDetailModel> getFaskesById(String faskesId) async {
    try {
      final response = await _apiClient.dio.get('/faskes/$faskesId');
      final payload = response.data;

      return FaskesDetailModel.fromJson(payload);
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil detail pengguna');
    } catch (e) {
      throw Exception('Terjadi kesalahan format data detail pengguna');
    }
  }

  Future<FaskesMutationResult> createFaskes(FaskesUpsertRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/faskes',
        data: request.toJson(),
      );

      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        return FaskesMutationResult.fromJson(payload);
      }

      throw Exception('Unexpected response format when creating faskes');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal membuat faskes baru');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat membuat faskes');
    }
  }

  Future<FaskesMutationResult> updateFaskes(
    String faskesId,
    FaskesUpsertRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '/faskes/$faskesId',
        data: request.toJson(),
      );

      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        return FaskesMutationResult.fromJson(payload);
      }

      throw Exception('Unexpected response format when updating faskes');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal memperbarui faskes');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memperbarui faskes');
    }
  }

  Future<String> deleteFaskes(String faskesId) async {
    try {
      final response = await _apiClient.dio.delete('/faskes/$faskesId');
      final payload = response.data;

      if (payload is Map<String, dynamic>) {
        return payload['message']?.toString() ?? 'Berhasil menghapus faskes';
      }

      return 'Berhasil menghapus faskes';
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal menghapus faskes');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghapus faskes');
    }
  }
}
