import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

/// Renders a date picker widget
class DateRangePickerWidget extends StatelessWidget {
  /// What happens when date range is selected
  final void Function(DateTime?, DateTime?) onSelect;
  /// Type of date picker view
  final DateRangePickerView view;
  /// Enable selection of dates in the past
  final bool datesInPast;
  /// Color of the range selection
  final Color rangeSelectionColor;
  /// Color of the end date selection
  final Color endRangeSelectionColor;
  /// Color of the start date selection
  final Color startRangeSelectionColor;
  /// Color of today`s cell
  final Color todayColor;

  const DateRangePickerWidget({
    super.key,
    required this.onSelect,
    this.datesInPast = false,
    this.view = DateRangePickerView.month,
    this.rangeSelectionColor = Colors.black38,
    this.endRangeSelectionColor = Colors.black,
    this.startRangeSelectionColor = Colors.black,
    this.todayColor = Colors.grey
  });

  @override
  Widget build(BuildContext context) => SfDateRangePicker(
      view: view,
      rangeSelectionColor: Colors.black38,
      endRangeSelectionColor: Colors.black,
      startRangeSelectionColor: Colors.black,
      todayHighlightColor: Colors.grey,
      backgroundColor: Colors.transparent,
      selectionMode: DateRangePickerSelectionMode.range,
      enablePastDates: datesInPast,
      headerStyle: const DateRangePickerHeaderStyle(
          textStyle: TextStyle(fontWeight: FontWeight.bold),
          backgroundColor: Colors.transparent
      ),
      onSelectionChanged: (DateRangePickerSelectionChangedArgs selection) => onSelect(selection.value.startDate, selection.value.endDate)
  );
}