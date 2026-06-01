class HomeSummaryModel {
  final String fullName;
  final String fase;
  final String? patientId;

  HomeSummaryModel({
    required this.fullName,
    required this.fase,
    this.patientId,
  });

  factory HomeSummaryModel.fromJson(Map<String, dynamic> json) {
    return HomeSummaryModel(
      fullName: json['fullName'] ?? 'Pengguna',
      fase: json['fase'] ?? 'Menunggu Data',
      patientId: json['patientId'], 
    );
  }
}