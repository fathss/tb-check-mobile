class UserDetailModel {
  final String id;
  final String fullName;
  final String email;
  final String nik;
  final bool isActive;
  final String status;
  final DateTime createdAt;

  UserDetailModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.nik,
    required this.isActive,
    required this.status,
    required this.createdAt,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      nik: json['nik'] as String,
      isActive: json['isActive'] as bool,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
