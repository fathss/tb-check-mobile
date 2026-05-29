class MedicineModel {
  final String name;

  final String function;

  final String dosage;

  final int stock;

  final List<String> schedules;

  final String consumeCondition;

  final List<bool> activeDays;

  final int selectedImageIndex;

  final bool isCompleted;

  final DateTime createdAt;

  MedicineModel({
    required this.name,
    required this.function,
    required this.dosage,
    required this.stock,
    required this.schedules,
    required this.consumeCondition,
    required this.activeDays,
    required this.selectedImageIndex,
    required this.isCompleted,
    required this.createdAt,
  });
}
