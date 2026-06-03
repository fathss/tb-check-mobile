class FaskesLocationSummaryModel {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String operatingHours;

  FaskesLocationSummaryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.operatingHours,
  });

  factory FaskesLocationSummaryModel.fromJson(Map<String, dynamic> json) {
    return FaskesLocationSummaryModel(
      id: _readString(json, const ['id', 'Id']),
      name: _readString(json, const ['name', 'Name']),
      type: _readString(json, const ['type', 'Type']),
      latitude: _readDouble(json, const ['latitude', 'Latitude']),
      longitude: _readDouble(json, const ['longitude', 'Longitude']),
      address: _readString(json, const ['address', 'Address']),
      operatingHours: _readString(json, const [
        'operatingHours',
        'OperatingHours',
      ]),
    );
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      return value.toString();
    }
  }

  return '';
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value != null) {
      return double.tryParse(value.toString()) ?? 0.0;
    }
  }

  return 0.0;
}
