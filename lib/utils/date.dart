import 'package:flutter/cupertino.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
/// Formatting a date
String formatDateUi(DateTime? date) => date == null ? '' : DateFormat('dd.MM.yyyy').format(date);
/// Formats how much time has passed from the given date
String formatTimeDifference(BuildContext context, DateTime? date) {
  if(date == null) {
    return '';
  }

  final currentTime = DateTime.now();
  final difference = currentTime.difference(date);

  final days = difference.inDays;

  String timeDifferenceText = '';
  if (days > 0) {
    if(days == 1) {
      return timeDifferenceText += '${translate('Before')} $days ${translate('day')}';
    }

    return timeDifferenceText += '${translate('Before')} $days ${translate('days')}';
  } else {
    return timeDifferenceText = translate('Today');
  }
}