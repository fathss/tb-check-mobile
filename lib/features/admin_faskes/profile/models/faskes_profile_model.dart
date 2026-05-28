class FaskesProfileModel {
  final String id;
  final String name;
  final String type;
  final String address;
  final String operatingHours;
  final String emergencyContact;
  final double latitude;
  final double longitude;

  FaskesProfileModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.operatingHours,
    required this.emergencyContact,
    required this.latitude,
    required this.longitude,
  });

  factory FaskesProfileModel.fromJson(Map<String, dynamic> json) {
    return FaskesProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      address: json['address'] ?? '',
      operatingHours: json['operatingHours'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
}