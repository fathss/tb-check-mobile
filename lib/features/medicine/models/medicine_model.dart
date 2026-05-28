class MedicineModel {
  final String name;
  final String dosage;

  final List<String> schedules;

  final String consumeCondition;

  final bool isCompleted;

  MedicineModel({
    required this.name,
    required this.dosage,
    required this.schedules,
    required this.consumeCondition,
    required this.isCompleted,
  });
}
