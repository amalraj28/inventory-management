import 'package:intl/intl.dart';

class Utils {
  static formatPrice(num price) => '\$ ${price.toStringAsFixed(2)}';
  static formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
}
