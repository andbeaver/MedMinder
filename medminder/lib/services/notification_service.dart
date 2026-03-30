import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medminder/models/prescription.dart';
import 'package:medminder/repositories/prescription_repository.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initNotification() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap or response here if needed.
      },
    );

    // Initialize timezone data for scheduled (zoned) notifications
    tz.initializeTimeZones();
    // Use system's local timezone; no need for flutter_native_timezone dependency

    _initialized = true;
  }


  NotificationDetails notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'medminder_channel',
      'MedMinder Notifications',
      channelDescription: 'Notifications for prescription refills',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'medminder_channel',
      'MedMinder Notifications',
      channelDescription: 'Notifications for prescription refills',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Schedule a notification for a single prescription.
  /// Schedules at 9:00 AM local time on (nextFillDate - noticeDays).
  Future<void> scheduleNotificationForPrescription(Prescription p) async {
    if (!_initialized) await initNotification();

    final scheduledDate = p.nextFillDate.subtract(Duration(days: p.noticeDays));
    final scheduledDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9,
    );

    if (scheduledDateTime.isBefore(DateTime.now())) {
      // Don't schedule notifications in the past - show immediately instead for testing
      print('Scheduled time is in the past, showing immediately: ${p.name}');
      try {
        await showNotification(
          id: p.id ?? p.hashCode,
          title: p.name,
          body: 'Refill due on ${p.nextFillDate.toLocal().toString().split(' ')[0]}',
        );
      } catch (e) {
        print('Failed to show immediate notification for ${p.name}: $e');
      }
      return;
    }

    final details = notificationDetails();

    try {
      await notificationsPlugin.zonedSchedule(
        id: p.id ?? p.hashCode,
        title: p.name,
        body: 'Refill due on ${p.nextFillDate.toLocal().toString().split(' ')[0]}',
        scheduledDate: tz.TZDateTime.from(scheduledDateTime, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } catch (e) {
      // Permission denied or other error; fail silently (can log in production)
      print('Failed to schedule notification for ${p.name}: $e');
    }
  }

  /// Cancel a scheduled notification by id.
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id: id);
  }

  /// Schedule notifications for all prescriptions in the database.
  Future<void> scheduleAllNotifications() async {
    try {
      final all = await PrescriptionRepository.getPrescriptions();
      for (final p in all) {
        await scheduleNotificationForPrescription(p);
      }
    } catch (e) {
      // Log but don't crash; app startup should not be blocked by notification errors
      print('Error scheduling all notifications: $e');
    }
  }
}