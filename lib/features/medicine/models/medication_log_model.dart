class MedicationLogModel {
  final String medicationName;
  final String scheduledTime;
  final String status;
  final String? takenTime;

  MedicationLogModel({
    required this.medicationName,
    required this.scheduledTime,
    required this.status,
    this.takenTime,
  });

  factory MedicationLogModel.fromJson(Map<String, dynamic> json) {
    return MedicationLogModel(
      medicationName: json['medicationName'] ?? '',
      scheduledTime: json['scheduledTime'] ?? '',
      status: json['status'] ?? 'pending',
      takenTime: json['takenTime'],
    );
  }
}