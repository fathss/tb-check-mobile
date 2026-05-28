class FaskesUpsertRequest {
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String emergencyContact;

  const FaskesUpsertRequest({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.emergencyContact,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'emergencyContact': emergencyContact,
    };
  }
}

class FaskesMutationResult {
  final String message;
  final String? faskesId;

  const FaskesMutationResult({required this.message, this.faskesId});

  factory FaskesMutationResult.fromJson(Map<String, dynamic> json) {
    return FaskesMutationResult(
      message: json['message']?.toString() ?? '',
      faskesId: json['faskesId']?.toString(),
    );
  }
}
