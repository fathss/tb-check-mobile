class SuperAdminDashboardModel {
  final int totalFaskes;
  final int totalAdmin;
  final int totalPatient;

  SuperAdminDashboardModel({
    required this.totalFaskes,
    required this.totalAdmin,
    required this.totalPatient,
  });

  factory SuperAdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return SuperAdminDashboardModel(
      totalFaskes: json['totalFaskes'] as int? ?? 0,
      totalAdmin: json['totalAdmin'] as int? ?? 0,
      totalPatient: json['totalPatient'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalFaskes': totalFaskes,
      'totalAdmin': totalAdmin,
      'totalPatient': totalPatient,
    };
  }
}
