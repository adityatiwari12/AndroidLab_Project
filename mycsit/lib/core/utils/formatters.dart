import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  static String dateStr(String s) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  static String shortDate(DateTime d) => DateFormat('dd MMM').format(d);

  static String relativeTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  static String score(double s) => s.toStringAsFixed(2);

  static String percent(double p) => '${p.toStringAsFixed(1)}%';
}
