class CreateAdminModel {
  final String username;
  final String email;
  final String faskesProfileId;

  CreateAdminModel({
    required this.username,
    required this.email,
    required this.faskesProfileId,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'faskesProfileId': faskesProfileId,
    };
  }
}
