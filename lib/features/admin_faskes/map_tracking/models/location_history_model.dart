class LocationHistoryModel {
  final String id;
  final double latitude;
  final double longitude;
  final String activityDescription; // Sesuaikan nama properti
  final DateTime timestamp;         // Sesuaikan nama properti

  LocationHistoryModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.activityDescription,
    required this.timestamp,
  });

  factory LocationHistoryModel.fromJson(Map<String, dynamic> json) {
    // Tangkap dari JSON API C# (kebal huruf besar/kecil)
    final rawLat = json['latitude'] ?? json['Latitude'] ?? 0.0;
    final rawLng = json['longitude'] ?? json['Longitude'] ?? 0.0;
    final rawDesc = json['activityDescription'] ?? json['ActivityDescription'] ?? 'Aktivitas tidak diketahui';
    final rawTime = json['timestamp'] ?? json['Timestamp'];

    return LocationHistoryModel(
      id: json['id'] ?? '',
      latitude: (rawLat as num).toDouble(),
      longitude: (rawLng as num).toDouble(),
      activityDescription: rawDesc,
      timestamp: rawTime != null ? DateTime.parse(rawTime) : DateTime.now(),
    );
  }
}