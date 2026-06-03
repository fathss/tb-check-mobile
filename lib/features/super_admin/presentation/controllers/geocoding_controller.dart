import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/geocoding_repository.dart';

final geocodingControllerProvider = Provider<GeocodingController>((ref) {
  return GeocodingController(ref);
});

class GeocodingController {
  final Ref _ref;

  GeocodingController(this._ref);

  Future<String> convertCoordinateToAddress(double lat, double lng) async {
    try {
      final repository = _ref.read(geocodingRepositoryProvider);
      return await repository.getAddressFromCoordinate(lat, lng);
    } catch (e) {
      rethrow;
    }
  }
}
