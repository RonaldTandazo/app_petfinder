import 'package:intl/intl.dart';

final DateFormat spanishDateFormat = DateFormat('dd MMM. yyyy', 'es');

String formatDate(Object? date) {
  if (date == null) return '';

  DateTime? parsedDate;

  if (date is DateTime) {
    parsedDate = date;
  } else if (date is String) {
    parsedDate = DateTime.tryParse(date);
  }

  if (parsedDate == null) return '';

  return DateFormat('dd MMM. yyyy', 'es').format(parsedDate);
}