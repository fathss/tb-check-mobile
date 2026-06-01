class MedicineModel {
  final String id;
  final String patientId;
  final String name;
  final String function;
  final int doseAmount;
  final int totalStock;
  final String iconType;
  final String consumeCondition;

  MedicineModel({
    required this.id,
    required this.patientId,
    required this.name,
    required this.function,
    required this.doseAmount,
    required this.totalStock,
    required this.iconType,
    required this.consumeCondition,
  });

  // Fungsi sakti untuk menerjemahkan balasan JSON dari API C#
  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      name: json['name'] ?? '',
      function: json['function'] ?? '',
      // Konversi aman untuk angka agar tidak error jika dari API terbaca sebagai string
      doseAmount: (json['doseAmount'] ?? 0).toInt(),
      totalStock: (json['totalStock'] ?? 0).toInt(),
      iconType: json['iconType'] ?? '',
      consumeCondition: json['consumeCondition'] ?? '',
    );
  }

  // Fungsi untuk mengirim data ke API C# (saat fitur tambah obat)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'name': name,
      'function': function,
      'doseAmount': doseAmount,
      'totalStock': totalStock,
      'iconType': iconType,
      'consumeCondition': consumeCondition,
    };
  }
}