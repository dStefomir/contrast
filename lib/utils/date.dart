import 'package:intl/intl.dart';
/// Formatting a date
String formatDateUi(DateTime? date) => date == null ? '' : DateFormat('dd.MM.yyyy').format(date);
/// Formats how much time has passed from the given date
String formatTimeDifference(DateTime? date) {
  if(date == null) {
    return '';
  }

  final currentTime = DateTime.now();
  final difference = currentTime.difference(date);

  final days = difference.inDays;

  String timeDifferenceText = '';
  if (days > 0) {
    if(days == 1) {
      timeDifferenceText += 'before $days day';
    }

    timeDifferenceText += 'before $days days';
  } else {
    timeDifferenceText = 'today';
  }

  return timeDifferenceText;
}