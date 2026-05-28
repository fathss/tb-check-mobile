class AdminModel {
  final String id;
  final String email;
  final String fullName;
  final bool? isActive;
  final DateTime? createdAt;

  AdminModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.isActive,
    this.createdAt,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
