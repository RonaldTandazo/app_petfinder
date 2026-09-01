import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DateSelectionType { single, range }

enum DateFilterType { none, disablePast, disableFuture }

class AppDatePicker extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateSelectionType selectionType;
  final DateFilterType filterType;
  final DateTime? selectedDate;
  final DateTimeRange? selectedRange;
  final List<DateTime>? blockedDates;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTimeRange>? onRangeSelected;
  final String? Function(String?)? validator;

  const AppDatePicker({
    super.key,
    required this.label,
    this.icon = Icons.calendar_today_rounded,
    this.selectionType = DateSelectionType.single,
    this.filterType = DateFilterType.none,
    this.selectedDate,
    this.selectedRange,
    this.blockedDates,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.onRangeSelected,
    this.validator,
  });

  bool _selectableDayPredicate(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(day.year, day.month, day.day);

    if (filterType == DateFilterType.disablePast && targetDay.isBefore(today)) {
      return false;
    }
    if (filterType == DateFilterType.disableFuture && targetDay.isAfter(today)) {
      return false;
    }

    if (blockedDates != null) {
      for (final blocked in blockedDates!) {
        final blockedNormalized = DateTime(blocked.year, blocked.month, blocked.day);
        if (targetDay.isAtSameMomentAs(blockedNormalized)) {
          return false;
        }
      }
    }

    return true;
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final effectiveFirst = firstDate ?? DateTime(now.year - 30);
    final effectiveLast = lastDate ?? DateTime(now.year + 10);

    if (selectionType == DateSelectionType.single) {
      final picked = await showDatePicker(
        context: context,
        locale: const Locale('es', 'ES'),
        initialDate: selectedDate ?? _getValidInitialDate(now, effectiveFirst, effectiveLast),
        firstDate: effectiveFirst,
        lastDate: effectiveLast,
        selectableDayPredicate: _selectableDayPredicate,
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.teal.shade600),
          ),
          child: child!,
        ),
      );

      if (picked != null && onDateSelected != null) {
        onDateSelected!(picked);
      }
    } else {
      final pickedRange = await showDateRangePicker(
        context: context,
        locale: const Locale('es', 'ES'),
        initialDateRange: selectedRange,
        firstDate: effectiveFirst,
        lastDate: effectiveLast,
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.teal.shade600),
          ),
          child: child!,
        ),
      );

      if (pickedRange != null && onRangeSelected != null) {
        onRangeSelected!(pickedRange);
      }
    }
  }

  DateTime _getValidInitialDate(DateTime now, DateTime first, DateTime last) {
    if (filterType == DateFilterType.disableFuture) {
      return now.isAfter(last) ? last : now;
    }
    if (filterType == DateFilterType.disablePast) {
      return now.isBefore(first) ? first : now;
    }
    return selectedDate ?? now;
  }

  String _getFormattedText() {
    final dateFormat = DateFormat('d MMM, yyyy', 'es');

    if (selectionType == DateSelectionType.single) {
      if (selectedDate != null) {
        return dateFormat.format(selectedDate!);
      }
      return 'Seleccionar fecha';
    } else {
      if (selectedRange != null) {
        return '${dateFormat.format(selectedRange!.start)} - ${dateFormat.format(selectedRange!.end)}';
      }
      return 'Seleccionar rango';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textValue = _getFormattedText();
    final hasValue = (selectionType == DateSelectionType.single && selectedDate != null) ||
        (selectionType == DateSelectionType.range && selectedRange != null);

    return FormField<String>(
      initialValue: hasValue ? textValue : null,
      validator: validator != null ? (_) => validator!(hasValue ? textValue : null) : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                await _pickDate(context);
                state.didChange(hasValue ? textValue : null);
              },
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon, size: 20, color: Colors.teal.shade600),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  errorText: state.errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: state.hasError ? Colors.red.shade400 : Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.teal.shade600, width: 1.5),
                  ),
                ),
                child: Text(
                  textValue,
                  style: TextStyle(
                    fontSize: 13,
                    color: hasValue ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}