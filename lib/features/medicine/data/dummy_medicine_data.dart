import '../models/medicine_model.dart';

final List<MedicineModel> medicineList = [
  MedicineModel(
    name: "Pyrazinamide",
    dosage: "500 mg",
    schedule: "07:00 am",
    consumeCondition: "After Eating",
    isCompleted: true,
  ),
  MedicineModel(
    name: "Rifampisin",
    dosage: "450 mg",
    schedule: "06:00 am",
    consumeCondition: "Before Eating",
    isCompleted: false,
  ),
];
