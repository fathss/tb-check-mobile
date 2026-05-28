class DateHelper {
  static List<DateTime> generateDates({
    required DateTime startDate,
    int totalDays = 30,
  }) {
    return List.generate(
      totalDays,

      (index) => startDate.add(Duration(days: index)),
    );
  }
}
