import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      // Ensure local timezone is correctly mapped from device offset
      try {
        final localOffset = DateTime.now().timeZoneOffset;
        final matchingLoc = tz.timeZoneDatabase.locations.values.firstWhere(
          (loc) => loc.currentTimeZone.offset == localOffset,
          orElse: () => tz.getLocation('UTC'),
        );
        tz.setLocalLocation(matchingLoc);
      } catch (_) {
        // Fallback to UTC if timezone lookup fails
      }

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
      );

      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        // Create high priority notification channel
        const channel = AndroidNotificationChannel(
          'bonfire_habits_channel',
          'Bonfire Yemin Bildirimleri',
          description: 'Günlük yemin ve alışkanlık hatırlatıcıları',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );
        await androidImplementation.createNotificationChannel(channel);
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }

      _isInitialized = true;
    } catch (_) {
      // Graceful fallback if notification subsystem is unavailable in current runtime
    }
  }

  /// Calculates the next TZDateTime for the given hour:minute
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Schedules a repeating daily notification at the given hour:minute for a task
  Future<void> scheduleHabitNotification({
    required int id,
    required String taskTitle,
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    final scheduledTime = _nextInstanceOfTime(hour, minute);

    const androidDetails = AndroidNotificationDetails(
      'bonfire_habits_channel',
      'Bonfire Yemin Bildirimleri',
      channelDescription: 'Günlük yemin ve alışkanlık hatırlatıcıları',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(sound: 'default'),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: '🔥 BONFIRE: $taskTitle',
        body: 'Vakit geldi kül doğuran. Bu yemini tamamla ve ateşini canlı tut!',
        scheduledDate: scheduledTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      try {
        // Fallback for devices restricting exact alarms
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: '🔥 BONFIRE: $taskTitle',
          body:
              'Vakit geldi kül doğuran. Bu yemini tamamla ve ateşini canlı tut!',
          scheduledDate: scheduledTime,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (_) {}
    }
  }

  /// Cancels scheduled notification for a task
  Future<void> cancelHabitNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (_) {}
  }

  /// Sends an immediate test notification to verify delivery on device
  Future<void> showImmediateTestNotification({
    String? title,
    String? body,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    const androidDetails = AndroidNotificationDetails(
      'bonfire_habits_channel',
      'Bonfire Yemin Bildirimleri',
      channelDescription: 'Günlük yemin ve alışkanlık hatırlatıcıları',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(sound: 'default'),
    );

    try {
      await _notificationsPlugin.show(
        id: 999999,
        title: title ?? '🔥 BONFIRE: Kadim Ateş Yanıyor',
        body: body ?? 'Bildirim sistemi başarıyla bağlandı. Yeminlerin koruma altında!',
        notificationDetails: notificationDetails,
      );
    } catch (_) {}
  }
}
