import 'package:intl/intl.dart';
/// Formatting a date
String formatDateUi(DateTime? date) => date == null ? '' : DateFormat('dd.MM.yyyy').format(date);