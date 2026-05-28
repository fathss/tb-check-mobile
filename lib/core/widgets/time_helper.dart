class TimeHelper {
  static String getPeriodLabel(String time) {
    final hour = int.parse(time.split(":")[0]);

    if (hour < 12) {
      return "Pagi";
    } else if (hour < 18) {
      return "Siang";
    } else {
      return "Malam";
    }
  }
}
