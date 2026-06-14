import 'package:health_care_app/core/services/notification_service.dart';
import 'package:health_care_app/core/utils/logger.dart';
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
      await _scheduleMedicineNotifications();
      await _scheduleMealNotifications();
    } catch (e) {
      Log.error('Notif', 'Error scheduling notifications: $e');
    }
  }

  Future<void> _scheduleMedicineNotifications() async {
    Log.info('Notif', 'Fetching today medicine doses...');
    final doses = await _api.getTodayDoses();

    for (var dose in doses) {
      final status = dose['status'];
      if (status == 'pending') {
        DateTime scheduledTime = DateTime.parse(dose['scheduled_for']);
        if (scheduledTime.isAfter(DateTime.now())) {
          int scheduleId = dose['schedule']['id'];
          int timeId = dose['schedule_time']['id'];
          int notificationId = scheduleId * 1000 + timeId;

          Log.info('Notif', 'Scheduling medicine ID $notificationId for ${dose['schedule']['medicine']['name']} at $scheduledTime');

          await _notificationService.scheduleNotification(
            id: notificationId,
            title: 'Waktunya Minum Obat!',
            body: '${dose['schedule']['medicine']['name']} - ${dose['schedule']['dose_per_intake']} unit',
            scheduledTime: scheduledTime,
            payload: scheduleId.toString(),
          );
        }
      }
    }
  }

  Future<void> _scheduleMealNotifications() async {
    Log.info('Notif', 'Fetching today meal schedules...');
    final meals = await _api.getTodayMeals();

    for (var meal in meals) {
      if (meal.mealTime == null || meal.id == null) continue;

      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final mealTimeStr = meal.mealTime!;
      final scheduledTime = mealTimeStr.contains('T') || mealTimeStr.contains(' ')
          ? DateTime.parse(mealTimeStr)
          : DateTime.parse('$todayStr $mealTimeStr');

      if (scheduledTime.isAfter(now)) {
        int notificationId = 1000000 + meal.id!;
        final mealName = meal.mealType?.name ?? 'Makan';
        final notes = meal.notes != null && meal.notes!.isNotEmpty ? ' - ${meal.notes}' : '';

        Log.info('Notif', 'Scheduling meal ID $notificationId for $mealName at $scheduledTime');

        await _notificationService.scheduleNotification(
          id: notificationId,
          title: 'Waktunya Makan!',
          body: '$mealName$notes',
          scheduledTime: scheduledTime,
          payload: meal.id.toString(),
        );
      }
    }
  }
}