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
