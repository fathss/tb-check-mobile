import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

import '../models/medicine_model.dart';
import '../repositories/medicine_repository.dart';
import '../services/medicine_api_service.dart';

final medicineApiServiceProvider = Provider(
  (ref) => MedicineApiService(ref.read(apiClientProvider)),
);

final medicineRepositoryProvider = Provider(
  (ref) => MedicineRepository(ref.read(medicineApiServiceProvider)),
);

final medicineProvider = FutureProvider.family<List<MedicineModel>, String>((
  ref,
  patientId,
) async {
  return ref.read(medicineRepositoryProvider).getMedicines(patientId);
});
