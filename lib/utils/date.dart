import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
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
      return timeDifferenceText += '${FlutterI18n.translate(context, 'Before')} $days ${FlutterI18n.translate(context, 'day')}';
    }

    return timeDifferenceText += '${FlutterI18n.translate(context, 'Before')} $days ${FlutterI18n.translate(context, 'days')}';
  } else {
    return timeDifferenceText = FlutterI18n.translate(context, 'Today');
  }
}