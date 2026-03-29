/// Shared date/time formatting utilities for display in the UI.
library;

/// Formats an ISO 8601 datetime string (e.g. '2026-03-29T07:00:00') or a date-only
/// string (e.g. '2026-03-29') into a human-friendly Indonesian format.
///
/// - Datetime →  'Sabtu, 29 Mar 2026  07:00'
/// - Date only →  '29 Mar 2026'
/// - null / unparseable → '-'
String formatDateTime(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw; // fallback: show as-is

  final day = _dayName(dt.weekday);
  final month = _monthAbbr(dt.month);
  final date = '${dt.day.toString().padLeft(2, '0')} $month ${dt.year}';

  // If it contains time component, show it too
  if (raw.contains('T') || raw.contains(' ')) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$day, $date  $h:$m';
  }
  return '$day, $date';
}

/// Formats an ISO datetime to short form: '29 Mar 2026, 07:00'
String formatDateTimeShort(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;

  final month = _monthAbbr(dt.month);
  final date = '${dt.day.toString().padLeft(2, '0')} $month ${dt.year}';

  if (raw.contains('T') || raw.contains(' ')) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$date, $h:$m';
  }
  return date;
}

/// Formats a date-only string '1990-06-15' → '15 Juni 1990'
String formatDateOnly(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  return '${dt.day.toString().padLeft(2, '0')} ${_monthFull(dt.month)} ${dt.year}';
}

/// Formats a time string 'HH:mm:ss' or 'HH:mm' → '07:00'
String formatTime(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final parts = raw.split(':');
  if (parts.length < 2) return raw;
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}

String _dayName(int weekday) {
  const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  return days[(weekday - 1).clamp(0, 6)];
}

String _monthAbbr(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return months[(month - 1).clamp(0, 11)];
}

String _monthFull(int month) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return months[(month - 1).clamp(0, 11)];
}
