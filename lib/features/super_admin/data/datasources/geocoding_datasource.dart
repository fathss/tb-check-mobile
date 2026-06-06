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
        'https://geocode.googleapis.com/v4/geocode/location/$lat,$lng',
        queryParameters: {
          'key': AppConstants.googleMapsKey,
          'languageCode': 'id', 
        },
      );

      // 1. API v4 langsung mengembalikan data jika sukses (HTTP 200). 
      // Kita langsung cek apakah ada objek 'results' dan tipenya List.
      if (response.data != null && response.data['results'] is List) {
        final results = response.data['results'] as List;
        
        if (results.isNotEmpty) {
          // 2. PERUBAHAN UTAMA: Gunakan 'formattedAddress' (camelCase), bukan 'formatted_address'
          final firstResult = results[0];
          if (firstResult['formattedAddress'] != null) {
            return firstResult['formattedAddress'] as String;
          }
        }
      }

      throw Exception('Alamat tidak ditemukan untuk koordinat tersebut');
    } on DioException catch (e) {
      // 3. API v4 mengembalikan detail error di dalam response.data['error'] jika HTTP status ganti (4xx/5xx)
      String errorMessage = 'Gagal menghubungi server Google Maps';
      if (e.response?.data != null && e.response?.data['error'] != null) {
        errorMessage = e.response?.data['error']['message'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memproses data alamat');
    }
  }
}
