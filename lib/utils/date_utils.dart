/// Converts a [DateTime] to Asia/Tashkent timezone (UTC+5).
///
/// The backend uses Asia/Tashkent timezone. When Dart parses ISO 8601 dates
/// with timezone offsets, it converts them to UTC internally. This extension
/// ensures dates are displayed exactly as stored in the backend.
extension TashkentDateTime on DateTime {
  /// Returns this date converted to Asia/Tashkent timezone (UTC+5).
  DateTime get toTashkent {
    final utc = toUtc();
    return utc.add(const Duration(hours: 5));
  }
}

/// Parses a date string and returns it in Asia/Tashkent timezone.
DateTime parseTashkentDate(String dateStr) {
  return DateTime.parse(dateStr).toTashkent;
}
