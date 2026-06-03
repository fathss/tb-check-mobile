class FaskesLocationDetailModel {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String operatingHours;
  final String emergencyContact;
  final int totalAdmin;

  FaskesLocationDetailModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.operatingHours,
    required this.emergencyContact,
    required this.totalAdmin,
  });

  factory FaskesLocationDetailModel.fromJson(Map<String, dynamic> json) {
    return FaskesLocationDetailModel(
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
      emergencyContact: _readString(json, const [
        'emergencyContact',
        'EmergencyContact',
      ]),
      totalAdmin: _readInt(json, const ['totalAdmin', 'TotalAdmin']),
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

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value != null) {
      return int.tryParse(value.toString()) ?? 0;
    }
  }

  return 0;
}
