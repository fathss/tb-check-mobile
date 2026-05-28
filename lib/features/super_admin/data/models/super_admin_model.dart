class SuperAdminModel {
  final String id;
  final String username;
  final String email;
  final String? password;

  SuperAdminModel({
    required this.id,
    required this.username,
    required this.email,
    this.password,
  });

  factory SuperAdminModel.fromJson(Map<String, dynamic> json) {
    return SuperAdminModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      password: "", // Set password string kosong
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
    };
  }
}
