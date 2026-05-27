class DashboardModel {
  final int totalCases;
  final int activePatients;
  final int recoveredPatients;

  DashboardModel({
    required this.totalCases,
    required this.activePatients,
    required this.recoveredPatients,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalCases: json['totalCases'] ?? 0,
      activePatients: json['activePatients'] ?? 0,
      recoveredPatients: json['recoveredPatients'] ?? 0,
    );
  }
}