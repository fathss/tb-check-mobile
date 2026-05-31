import 'dart:convert';

class MedicineModel {
  final String id;

  final String patientId;

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
    required this.id,
    required this.patientId,
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

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',

      name: json['name'] ?? '',

      function: json['function'] ?? '',

      dosage: json['dosage'] ?? '',

      stock: json['stock'] ?? 0,

      schedules: List<String>.from(jsonDecode(json['schedulesJson'] ?? '[]')),

      consumeCondition: json['consumeCondition'] ?? '',

      activeDays: List<bool>.from(jsonDecode(json['activeDaysJson'] ?? '[]')),

      selectedImageIndex: json['selectedImageIndex'] ?? 0,

      isCompleted: json['isCompleted'] ?? false,

      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'name': name,
      'function': function,
      'dosage': dosage,
      'stock': stock,
      'schedules': schedules,
      'consumeCondition': consumeCondition,
      'activeDays': activeDays,
      'selectedImageIndex': selectedImageIndex,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
