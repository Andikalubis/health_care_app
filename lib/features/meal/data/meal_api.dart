import 'package:health_care_app/core/network/base_api.dart';
import 'package:health_care_app/features/meal/data/models/meal_type_model.dart';
import 'package:health_care_app/features/meal/data/models/meal_schedule_model.dart';

mixin MealApi on BaseApi {
  // ─── MEAL TYPES ───────────────────────────────────────────
  Future<List<MealTypeModel>> getMealTypes() async {
    final res = await dio.get('/meal-types');
    final data = unwrap(res);
    return (data as List).map((e) => MealTypeModel.fromJson(e)).toList();
  }

  Future<MealTypeModel> storeMealType(MealTypeModel model) async {
    final res = await dio.post('/meal-types', data: model.toJson());
    return MealTypeModel.fromJson(unwrap(res));
  }

  Future<MealTypeModel> updateMealType(int id, MealTypeModel model) async {
    final res = await dio.put('/meal-types/$id', data: model.toJson());
    return MealTypeModel.fromJson(unwrap(res));
  }

  Future<void> deleteMealType(int id) async {
    await dio.delete('/meal-types/$id');
  }

  // ─── MEAL SCHEDULES ───────────────────────────────────────
  Future<List<MealScheduleModel>> getMealSchedules() async {
    final res = await dio.get('/meal-schedules');
    final data = unwrap(res);
    return (data as List).map((e) => MealScheduleModel.fromJson(e)).toList();
  }

  Future<MealScheduleModel> storeMealSchedule(MealScheduleModel model) async {
    final res = await dio.post('/meal-schedules', data: model.toJson());
    return MealScheduleModel.fromJson(unwrap(res));
  }

  Future<MealScheduleModel> updateMealSchedule(
    int id,
    MealScheduleModel model,
  ) async {
    final res = await dio.put('/meal-schedules/$id', data: model.toJson());
    return MealScheduleModel.fromJson(unwrap(res));
  }

  Future<void> deleteMealSchedule(int id) async {
    await dio.delete('/meal-schedules/$id');
  }

  Future<List<MealScheduleModel>> getTodayMeals() async {
    final res = await dio.get('/meal-schedules/today');
    final data = unwrap(res);
    return (data as List).map((e) => MealScheduleModel.fromJson(e)).toList();
  }
}
