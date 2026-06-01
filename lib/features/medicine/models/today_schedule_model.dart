class TodayScheduleModel {
  final String scheduleId;
  final String time;
  final String title;
  final String subtitle;
  final bool isDone;

  TodayScheduleModel({
    required this.scheduleId,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.isDone,
  });

  factory TodayScheduleModel.fromJson(Map<String, dynamic> json) {
    return TodayScheduleModel(
      scheduleId: json['scheduleId'] ?? '',
      time: json['time'] ?? '00:00',
      title: json['title'] ?? 'Nama Obat',
      subtitle: json['subtitle'] ?? 'Aturan pakai',
      isDone: json['isDone'] ?? false,
    );
  }
}