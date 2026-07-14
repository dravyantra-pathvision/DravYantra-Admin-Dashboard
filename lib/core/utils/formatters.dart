// core/utils/formatters.dart
// App-wide formatting utilities.

import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _date     = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final _time     = DateFormat('hh:mm a');
  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final _compact  = NumberFormat.compact();
  static final _number   = NumberFormat('#,##,###');

  static String date(DateTime? dt)     => dt == null ? '—' : _date.format(dt.toLocal());
  static String dateTime(DateTime? dt) => dt == null ? '—' : _dateTime.format(dt.toLocal());
  static String time(DateTime? dt)     => dt == null ? '—' : _time.format(dt.toLocal());
  static String currency(num? v)       => v == null ? '—' : _currency.format(v);
  static String compact(num? v)        => v == null ? '—' : _compact.format(v);
  static String number(num? v)         => v == null ? '—' : _number.format(v);

  static String dateFromString(String? s) {
    if (s == null || s.isEmpty) return '—';
    try { return date(DateTime.parse(s)); } catch (_) { return s; }
  }

  static String timeAgo(DateTime? dt) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inSeconds < 60)  return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    if (diff.inDays < 30)     return '${diff.inDays}d ago';
    return date(dt);
  }
}
