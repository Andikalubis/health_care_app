import 'package:flutter/foundation.dart';
import 'package:health_care_app/core/services/notification_service.dart';
import 'package:health_care_app/features/auth/data/api_service.dart';

class NotificationSchedulerService {
  static final NotificationSchedulerService _instance =
      NotificationSchedulerService._internal();
  factory NotificationSchedulerService() => _instance;
  NotificationSchedulerService._internal();

  final _api = ApiService();
  final _notificationService = LocalNotificationService();

  Future<void> scheduleTodayNotifications() async {
    try {
      if (kDebugMode) {
        print('NotificationSchedulerService: Fetching today doses...');
      }
      final doses = await _api.getTodayDoses();

      // Cancel existing schedules to avoid duplicates
      // await _notificationService.cancelAllNotifications();

      for (var dose in doses) {
        final status = dose['status'];
        if (status == 'pending') {
          DateTime scheduledTime = DateTime.parse(dose['scheduled_for']);
          if (scheduledTime.isAfter(DateTime.now())) {
            int scheduleId = dose['schedule']['id'];
            int timeId = dose['schedule_time']['id'];
            int notificationId =
                scheduleId * 1000 + timeId; // Unique ID per dose time

            if (kDebugMode) {
              print(
                'NotificationSchedulerService: Scheduling ID $notificationId for ${dose['schedule']['medicine']['name']} at $scheduledTime',
              );
            }

            await _notificationService.scheduleNotification(
              id: notificationId,
              title: 'Waktunya Minum Obat!',
              body:
                  '${dose['schedule']['medicine']['name']} - ${dose['schedule']['dose_per_intake']} unit',
              scheduledTime: scheduledTime,
              payload: scheduleId.toString(),
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('NotificationSchedulerService: Error scheduling: $e');
      }
    }
  }
}
