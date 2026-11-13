import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/weekly_reminder.dart';

/// Cài đặt [WeeklyReminder] bằng thông báo cục bộ lặp lại (FR-19, AD-14).
class LocalNotificationWeeklyReminder implements WeeklyReminder {
  LocalNotificationWeeklyReminder({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const int _id = 7001;
  static const String _zone = 'Asia/Ho_Chi_Minh';

  /// 09:30 thứ Hai giờ Việt Nam: nến BTC đóng lúc 07:00, nến VNINDEX được
  /// adapter coi là đóng lúc 09:00 (mở + 7 ngày, AD-4). Nửa tiếng đệm.
  static const int _hour = 9;
  static const int _minute = 30;

  bool _initialized = false;

  @override
  Future<void> ensureScheduled(ReminderText text) async {
    try {
      if (!_initialized) {
        tzdata.initializeTimeZones();
        await _plugin.initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings(),
          ),
        );
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        _initialized = true;
      }

      await _plugin.zonedSchedule(
        id: _id,
        scheduledDate: nextMondayMorning(tz.TZDateTime.now(tz.getLocation(_zone))),
        title: text.title,
        body: text.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_close',
            text.channelName,
            channelDescription: text.channelDescription,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        // Không cần giờ chính xác tới phút, nên không xin quyền exact alarm.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (error) {
      // Không có quyền hay plugin hỏng thì chỉ mất lời nhắc; app vẫn chạy.
      debugPrint('WeeklyReminder: không đặt được lịch — $error');
    }
  }

  /// Lần thứ Hai 09:30 kế tiếp **sau** [now] (cùng múi giờ với [now]).
  @visibleForTesting
  static tz.TZDateTime nextMondayMorning(tz.TZDateTime now) {
    var at = tz.TZDateTime(now.location, now.year, now.month, now.day, _hour, _minute);
    at = at.add(Duration(days: (DateTime.monday - at.weekday) % 7));
    if (!at.isAfter(now)) at = at.add(const Duration(days: 7));
    return at;
  }
}
