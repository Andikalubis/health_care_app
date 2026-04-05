import 'package:dio/dio.dart';
import 'package:health_care_app/core/network/base_api.dart';
import 'package:health_care_app/features/notification/data/models/notification_model.dart';
import 'package:health_care_app/features/notification/data/models/master_notification_model.dart';

mixin NotificationApi on BaseApi {
  // ─── NOTIFICATIONS ────────────────────────────────────────
  Future<List<NotificationModel>> getNotifications() async {
    final res = await dio.get('/notifications');
    final data = unwrap(res);
    return (data as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> deleteNotification(int id) async {
    await dio.delete('/notifications/$id');
  }

  Future<void> markAsRead(int id) async {
    await dio.put('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await dio.put('/notifications/read-all');
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      // Primary attempt: standard hyphenated
      final res = await dio.get(
        '/notifications/unread-count',
        options: Options(extra: {'silent': true}),
      );
      final data = unwrap(res);
      return data['unread_count'] ?? data['count'] ?? 0;
    } catch (_) {
      try {
        // Fallback 1: underscore version
        final res = await dio.get(
          '/notifications/unread_count',
          options: Options(extra: {'silent': true}),
        );
        final data = unwrap(res);
        return data['unread_count'] ?? data['count'] ?? 0;
      } catch (_) {
        try {
          // Fallback 2: hyphenated typo (as mentioned in user request)
          final res = await dio.get(
            '/notifications/uread-count',
            options: Options(extra: {'silent': true}),
          );
          final data = unwrap(res);
          return data['unread_count'] ?? data['count'] ?? 0;
        } catch (_) {
          return 0; // Fail gracefully
        }
      }
    }
  }

  // ─── MASTER NOTIFICATIONS ─────────────────────────────────
  Future<List<MasterNotificationModel>> getMasterNotifications() async {
    final res = await dio.get('/master-notifications');
    final data = unwrap(res);
    return (data as List)
        .map((e) => MasterNotificationModel.fromJson(e))
        .toList();
  }

  Future<MasterNotificationModel> storeMasterNotification(
    MasterNotificationModel model,
  ) async {
    final res = await dio.post('/master-notifications', data: model.toJson());
    return MasterNotificationModel.fromJson(unwrap(res));
  }

  Future<MasterNotificationModel> updateMasterNotification(
    int id,
    MasterNotificationModel model,
  ) async {
    final res = await dio.put(
      '/master-notifications/$id',
      data: model.toJson(),
    );
    return MasterNotificationModel.fromJson(unwrap(res));
  }

  Future<void> deleteMasterNotification(int id) async {
    await dio.delete('/master-notifications/$id');
  }
}
