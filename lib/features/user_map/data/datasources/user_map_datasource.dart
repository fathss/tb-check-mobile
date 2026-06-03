import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tbcheck_app/core/network/api_client.dart';

import '../models/faskes_location_summary_model.dart';

final userMapDatasourceProvider = Provider<UserMapDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserMapDatasource(apiClient);
});

class UserMapDatasource {
  final ApiClient _apiClient;

  UserMapDatasource(this._apiClient);

  Future<List<FaskesLocationSummaryModel>> getFaskesList() async {
    try {
      final response = await _apiClient.dio.get('/user/faskes');
      final payload = response.data;

      if (payload is List) {
        return payload
            .map<FaskesLocationSummaryModel>(
              (item) => FaskesLocationSummaryModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }

      if (payload is Map && payload['data'] is List) {
        return (payload['data'] as List)
            .map<FaskesLocationSummaryModel>(
              (item) => FaskesLocationSummaryModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }

      throw Exception('Format respons faskes tidak dikenali');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil daftar faskes');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat membaca daftar faskes');
    }
  }
}
