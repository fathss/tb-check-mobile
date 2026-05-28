import 'admin_model.dart';

class FaskesDetailModel {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String operatingHours;
  final String emergencyContact;
  final int totalAdmin;
  final List<AdminModel> admins;

  FaskesDetailModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.operatingHours,
    required this.emergencyContact,
    required this.totalAdmin,
    required this.admins,
  });

  factory FaskesDetailModel.fromJson(Map<String, dynamic> json) {
    return FaskesDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString() ?? '',
      operatingHours: json['operatingHours']?.toString() ?? '',
      emergencyContact: json['emergencyContact']?.toString() ?? '',
      totalAdmin: json['totalAdmin'] as int? ?? 0,
      admins: json['admins'] != null
          ? (json['admins'] as List)
                .map<AdminModel>(
                  (admin) => AdminModel.fromJson(admin as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }
}
