import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/medicine_model.dart';
import '../models/medicine_consumption_log_model.dart';
import '../providers/medicine_provider.dart';
import '../providers/medicine_consumption_log_provider.dart';

class MedicineActionHelper {
  static Future<void> markAsTaken({
    required WidgetRef ref,
    required MedicineModel medicine,
    required String scheduleTime,
  }) async {
    final log = MedicineConsumptionLogModel(
      medicineId: medicine.id,
      patientId: medicine.patientId,
      scheduleTime: scheduleTime,
      status: "Taken",
      consumedAt: DateTime.now(),
    );

    await ref.read(medicineConsumptionLogRepositoryProvider).createLog(log);

    await ref.read(medicineRepositoryProvider).decreaseStock(medicine.id);

    ref.invalidate(medicineProvider(medicine.patientId));
  }
}
