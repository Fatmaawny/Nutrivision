/// Date keys used as Firestore document ids (yyyy-MM-dd).
class DateKeys {
  DateKeys._();

  static String forDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String today() => forDate(DateTime.now());
}
