import '../models/medicine_model.dart';

final List<MedicineModel> medicineList = [
  MedicineModel(
    name: "Pyrazinamide",
    dosage: "500 mg",

    schedules: ["07:00", "19:00"],

    consumeCondition: "After Eating",

    isCompleted: true,
    createdAt: DateTime(2026, 5, 20),
  ),

  MedicineModel(
    name: "Rifampisin",

    dosage: "450 mg",

    schedules: ["06:00", "19:00"],

    consumeCondition: "Sebelum Makan",

    isCompleted: false,

    createdAt: DateTime(2026, 5, 20),
  ),

  MedicineModel(
    name: "Isoniazid",
    dosage: "300 mg",

    schedules: ["08:00", "20:00"],

    consumeCondition: "Sebelum Makan",

    isCompleted: false,
    createdAt: DateTime(2026, 5, 20),
  ),

  MedicineModel(
    name: "Ethambutol",
    dosage: "250 mg",

    schedules: ["13:00"],

    consumeCondition: "After Eating",

    isCompleted: true,
    createdAt: DateTime(2026, 5, 20),
  ),
];
