class MedicineConsumptionLogModel {
  final String medicineId;
  final String patientId;
  final String scheduleTime;
  final String status;
  final DateTime? consumedAt;

  MedicineConsumptionLogModel({
    required this.medicineId,
    required this.patientId,
    required this.scheduleTime,
    required this.status,
    this.consumedAt,
  });

  factory MedicineConsumptionLogModel.fromJson(Map<String, dynamic> json) {
    return MedicineConsumptionLogModel(
      medicineId: json['medicineId'],
      patientId: json['patientId'],
      scheduleTime: json['scheduleTime'],
      status: json['status'],
      consumedAt: DateTime.parse(json['consumedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "medicineId": medicineId,
      "patientId": patientId,
      "scheduleTime": scheduleTime,
      "status": status,
    };
  }
}
