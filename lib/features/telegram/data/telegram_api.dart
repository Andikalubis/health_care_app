import 'package:health_care_app/core/network/base_api.dart';
import 'package:health_care_app/features/telegram/data/models/telegram_user_model.dart';

mixin TelegramApi on BaseApi {
  Future<List<TelegramUserModel>> getTelegramUsers() async {
    final res = await dio.get('/telegram-users');
    final data = unwrap(res);
    return (data as List).map((e) => TelegramUserModel.fromJson(e)).toList();
  }

  Future<TelegramUserModel> getTelegramUser(int id) async {
    final res = await dio.get('/telegram-users/$id');
    return TelegramUserModel.fromJson(unwrap(res));
  }

  Future<TelegramUserModel> storeTelegramUser(TelegramUserModel model) async {
    final res = await dio.post('/telegram-users', data: model.toJson());
    return TelegramUserModel.fromJson(unwrap(res));
  }

  Future<TelegramUserModel> updateTelegramUser(
    int id,
    TelegramUserModel model,
  ) async {
    final res = await dio.put('/telegram-users/$id', data: model.toJson());
    return TelegramUserModel.fromJson(unwrap(res));
  }

  Future<void> deleteTelegramUser(int id) async {
    await dio.delete('/telegram-users/$id');
  }

  Future<Map<String, dynamic>> subscribeLinkByEmail(String email) async {
    final res = await dio.post(
      '/telegram/subscribe-link-by-email',
      data: {'email': email},
    );
    return unwrap(res);
  }
}
