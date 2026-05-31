import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

import '../models/medicine_consumption_log_model.dart';
import '../repositories/medicine_consumption_log_repository.dart';
import '../services/medicine_consumption_log_api_service.dart';

final medicineConsumptionLogApiServiceProvider = Provider(
  (ref) => MedicineConsumptionLogApiService(ref.read(apiClientProvider)),
);

final medicineConsumptionLogRepositoryProvider = Provider(
  (ref) => MedicineConsumptionLogRepository(
    ref.read(medicineConsumptionLogApiServiceProvider),
  ),
);

final medicineConsumptionLogsProvider =
    FutureProvider.family<List<MedicineConsumptionLogModel>, String>((
      ref,
      patientId,
    ) async {
      return ref
          .read(medicineConsumptionLogRepositoryProvider)
          .getLogs(patientId);
    });
