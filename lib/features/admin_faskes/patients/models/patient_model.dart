class PatientModel {
  final String id;
  final String nik;
  final String fullName;
  final String tbType;
  final String status;
  final DateTime diagnosisDate;
  final String? address;
  final double? latitude;
  final double? longitude;

  PatientModel({
    required this.id,
    required this.nik,
    required this.fullName,
    required this.tbType,
    required this.status,
    required this.diagnosisDate,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? '',
      nik: json['nik'] ?? '',
      fullName: json['fullName'] ?? '',
      tbType: json['tbType'] ?? '',
      status: json['status'] ?? 'Aktif',
      diagnosisDate: json['diagnosisDate'] != null 
          ? DateTime.parse(json['diagnosisDate']) 
          : DateTime.now(),
      address: json['address'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }
}