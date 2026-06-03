import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/geocoding_datasource.dart';

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  final datasource = ref.watch(geocodingDatasourceProvider);
  return GeocodingRepository(datasource);
});

class GeocodingRepository {
  final GeocodingDatasource _datasource;

  GeocodingRepository(this._datasource);

  Future<String> getAddressFromCoordinate(double lat, double lng) async {
    try {
      return await _datasource.getAddressFromCoordinate(lat, lng);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
