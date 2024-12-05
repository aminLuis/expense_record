import 'package:intl/intl.dart';

class FormatDate {
  static String fullDateFormat(DateTime date) {
    String resDate = "";
    resDate = DateFormat("MMM d 'de' yyyy", 'es').format(date);
    return resDate;
  }

  static String shortDateFormatEnd(DateTime date) {
    String resDate = "";
    resDate = DateFormat("MMM 'de' yyyy", 'es').format(date);
    return resDate;
  }

  static String shortDateFormatStart(DateTime date) {
    String resDate = "";
    resDate = DateFormat("MMM d", 'es').format(date);
    return resDate;
  }

  static String shortDateFormatMonth(DateTime date) {
    String resDate = "";
    resDate = DateFormat("MMM", 'es').format(date);
    return resDate;
  }
}