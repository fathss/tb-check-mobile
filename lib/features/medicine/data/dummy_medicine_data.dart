import '../models/medicine_model.dart';

final List<MedicineModel> medicineList = [
  MedicineModel(
    name: "Pyrazinamide",
    dosage: "500 mg",

    schedules: ["07:00", "19:00"],

    consumeCondition: "After Eating",

    isCompleted: true,
  ),

  MedicineModel(
    name: "Rifampisin",
    dosage: "450 mg",

    schedules: ["06:00"],

    consumeCondition: "Sesudah Makan",

    isCompleted: false,
  ),

  MedicineModel(
    name: "Isoniazid",
    dosage: "300 mg",

    schedules: ["08:00", "20:00"],

    consumeCondition: "Sebelum Makan",

    isCompleted: false,
  ),

  MedicineModel(
    name: "Ethambutol",
    dosage: "250 mg",

    schedules: ["13:00"],

    consumeCondition: "After Eating",

    isCompleted: true,
  ),
];
