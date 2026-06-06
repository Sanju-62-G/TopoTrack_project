import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: android);

    await _notifications.initialize(settings);
  }

  static Future<void> scheduleDeadlineReminders({
    required String title,
    required DateTime deadlineAt,
    required int baseId,
  }) async {
    final now = DateTime.now();

    // 3 days before
    final threeDays =
        deadlineAt.subtract(const Duration(days: 3));
    if (threeDays.isAfter(now)) {
      await _schedule(
        id: baseId,
        title: 'Deadline in 3 days!',
        body: title,
        scheduledDate: threeDays,
      );
    }

    // 1 day before
    final oneDay =
        deadlineAt.subtract(const Duration(days: 1));
    if (oneDay.isAfter(now)) {
      await _schedule(
        id: baseId + 1,
        title: 'Deadline tomorrow!',
        body: title,
        scheduledDate: oneDay,
      );
    }

    // 2 hours before
    final twoHours =
        deadlineAt.subtract(const Duration(hours: 2));
    if (twoHours.isAfter(now)) {
      await _schedule(
        id: baseId + 2,
        title: 'Only 2 hours left!',
        body: title,
        scheduledDate: twoHours,
      );
    }
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_channel',
          'Deadline Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
