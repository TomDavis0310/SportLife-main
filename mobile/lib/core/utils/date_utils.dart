import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _fullDateFormat = DateFormat('EEEE, dd MMMM yyyy', 'vi_VN');
  static final _monthYearFormat = DateFormat('MMMM yyyy', 'vi_VN');

  static String formatDate(DateTime? date) {
    if (date == null) return '--';
    return _dateFormat.format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return '--';
    return _timeFormat.format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '--';
    return _dateTimeFormat.format(date);
  }

  static String formatFullDate(DateTime? date) {
    if (date == null) return '--';
    return _fullDateFormat.format(date);
  }

  static String formatMonthYear(DateTime? date) {
    if (date == null) return '--';
    return _monthYearFormat.format(date);
  }

  static String formatRelative(DateTime? date) {
    if (date == null) return '--';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    }
    return '${(difference.inDays / 365).floor()} năm trước';
  }

  static String formatMatchTime(DateTime matchTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final matchDate = DateTime(matchTime.year, matchTime.month, matchTime.day);

    if (matchDate == today) {
      return 'Hôm nay, ${_timeFormat.format(matchTime)}';
    } else if (matchDate == tomorrow) {
      return 'Ngày mai, ${_timeFormat.format(matchTime)}';
    }
    return '${_dateFormat.format(matchTime)} ${_timeFormat.format(matchTime)}';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}


