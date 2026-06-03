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

  // --- TAMBAHKAN GETTER DI SINI ---
  String get displayStatus {
    final s = status.toLowerCase();
    if (s.contains('aktif')) {
      return 'Aktif Dirawat';
    } else if (s.contains('drop')) {
      return 'Drop-out';
    } else if (s.contains('sembuh')) {
      return 'Sembuh';
    }
    return status; 
  }
  // --------------------------------

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
    // Tangkap baik huruf kecil maupun huruf besar dari JSON (Kebal dari C#)
    final rawLat = json['latitude'] ?? json['Latitude'];
    final rawLng = json['longitude'] ?? json['Longitude'];
    final rawAddress = json['address'] ?? json['Address']; // <-- INI YANG TERTINGGAL

    return PatientModel(
      id: json['id'] ?? '',
      nik: json['nik'] ?? '',
      fullName: json['fullName'] ?? '',
      tbType: json['tbType'] ?? '',
      status: json['status'] ?? '',
      // Lebih aman agar tidak crash jika tanggal dari API null
      diagnosisDate: json['diagnosisDate'] != null 
          ? DateTime.parse(json['diagnosisDate']) 
          : DateTime.now(), 
      
      address: rawAddress, // <-- MASUKKAN TANGKAPAN ALAMATNYA DI SINI
      latitude: rawLat != null ? (rawLat as num).toDouble() : null,
      longitude: rawLng != null ? (rawLng as num).toDouble() : null,
    );
  }
}