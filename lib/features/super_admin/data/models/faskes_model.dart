class FaskesModel {
  final String id;
  final String name;
  final String type;
  final String address;
  final int totalAdmin;

  FaskesModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.totalAdmin,
  });

  factory FaskesModel.fromJson(Map<String, dynamic> json) {
    return FaskesModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      address: json['address'] as String,
      totalAdmin: json['totalAdmin'] as int,
    );
  }
}
