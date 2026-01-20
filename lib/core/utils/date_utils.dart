class DateUtils {
  static DateTime now() => DateTime.now();
  
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }
  
  static DateTime addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }
  
  static bool isToday(DateTime date) {
    final today = DateUtils.today();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }
  
  static bool isPast(DateTime date) {
    return date.isBefore(today());
  }
  
  static bool isFuture(DateTime date) {
    return date.isAfter(today());
  }
  
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }
}
