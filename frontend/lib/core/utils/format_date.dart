import 'package:intl/intl.dart';
import 'package:university_qa_system/core/error/exceptions.dart';

String formatDate(String dateString) {
  try {
    final DateTime dateTime = DateTime.parse(dateString);
    final DateFormat formatter = DateFormat('HH:mm - dd/MM/yyyy');
    return formatter.format(dateTime);
  } catch (e) {
    throw ServerException('Invalid date format: $dateString');
  }
}