import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medminder/models/prescription.dart';
import 'package:medminder/repositories/prescription_repository.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  factory NotificationService() => _instance;

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

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

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

  /// Schedule two notifications for a single prescription:
  /// - Reminder: 3 days before refill at 9:00 AM
  /// - Due: On refill date at 9:00 AM
  Future<void> scheduleNotificationForPrescription(Prescription p) async {
    if (!_initialized) await initNotification();

    final prescriptionId = p.id ?? p.hashCode;
    final details = notificationDetails();

    // Notification 1: Reminder 3 days before refill
    final reminderDate = p.nextFillDate.subtract(Duration(days: 3));
    final reminderDateTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
    );

    if (reminderDateTime.isAfter(DateTime.now())) {
      try {
        await notificationsPlugin.zonedSchedule(
          id: prescriptionId * 2,
          title: '${p.name} - Reminder',
          body: 'Refill in 3 days',
          scheduledDate: tz.TZDateTime.from(reminderDateTime, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to schedule reminder notification for ${p.name}: $e');
        }
      }
    } else {
      try {
        await showNotification(
          id: prescriptionId * 2,
          title: '${p.name} - Reminder',
          body: 'Refill in 3 days',
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to show immediate reminder for ${p.name}: $e');
        }
      }
    }

    // Notification 2: Due on refill date
    final dueDateTime = DateTime(
      p.nextFillDate.year,
      p.nextFillDate.month,
      p.nextFillDate.day,
      9,
    );

    if (dueDateTime.isAfter(DateTime.now())) {
      try {
        await notificationsPlugin.zonedSchedule(
          id: prescriptionId * 2 + 1,
          title: '${p.name} - Refill Due',
          body: 'Time to refill your medication',
          scheduledDate: tz.TZDateTime.from(dueDateTime, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to schedule due notification for ${p.name}: $e');
        }
      }
    } else {
      try {
        await showNotification(
          id: prescriptionId * 2 + 1,
          title: '${p.name} - Refill Due',
          body: 'Time to refill your medication',
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to show immediate due notification for ${p.name}: $e');
        }
      }
    }
  }

  /// Cancel both scheduled notifications for a prescription by id.
  /// Each prescription has two notifications: reminder (id*2) and due (id*2+1).
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id: id * 2);
    await notificationsPlugin.cancel(id: id * 2 + 1);
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
      if (kDebugMode) {
        debugPrint('Error scheduling all notifications: $e');
      }
    }
  }
}