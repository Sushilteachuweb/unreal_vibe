import 'package:intl/intl.dart';

class DateFormatter {
  /// Formats a date string to show month, date and day (e.g., "Oct 31 | Thu")
  static String formatToDateAndDay(String dateString) {
    try {
      // Parse the date string (assuming format like "Oct 31, 2024")
      DateTime parsedDate = DateFormat('MMM d, yyyy').parse(dateString);
      
      // Format to show month short form, date, pipe separator, and abbreviated day name
      String month = DateFormat('MMM').format(parsedDate);
      String day = DateFormat('d').format(parsedDate);
      String dayName = DateFormat('E').format(parsedDate);
      
      return '$month $day | $dayName';
    } catch (e) {
      // If parsing fails, try to extract components from the original string
      try {
        // Extract month, day from strings like "Oct 31, 2024"
        RegExp dateRegex = RegExp(r'(\w{3})\s+(\d{1,2})');
        Match? match = dateRegex.firstMatch(dateString);
        if (match != null) {
          String month = match.group(1)!;
          String day = match.group(2)!;
          return '$month $day | Day';
        }
      } catch (e) {
        // Fallback to original string if all parsing fails
        return dateString;
      }
      return dateString;
    }
  }
}