import 'package:intl/intl.dart';

class Formatnumber {

  static String formatNumber(double number) {
    return NumberFormat.decimalPattern('es').format(number);
  }
}