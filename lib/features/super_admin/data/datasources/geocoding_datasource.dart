import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/constants/app_constants.dart';

final geocodingDatasourceProvider = Provider<GeocodingDatasource>((ref) {
  return GeocodingDatasource();
});

class GeocodingDatasource {
  final Dio _dio = Dio();

  Future<String> getAddressFromCoordinate(double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': AppConstants.googleMapsKey,
          'language': 'id', // Memastikan alamat dalam Bahasa Indonesia
        },
      );

      if (response.data['status'] == 'OK') {
        // 'results' mengembalikan array alamat. Indeks 0 adalah yang paling spesifik/detail.
        final results = response.data['results'] as List;
        if (results.isNotEmpty) {
          return results[0]['formatted_address'] as String;
        }
      } else {
        throw Exception(
          response.data['error_message'] ?? 'Gagal mengambil alamat',
        );
      }

      throw Exception('Alamat tidak ditemukan untuk koordinat tersebut');
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal menghubungi server Google Maps');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memproses data alamat');
    }
  }
}
