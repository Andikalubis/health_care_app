import 'package:health_care_app/core/network/base_api.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_model.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_schedule_model.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_history_model.dart';

mixin MedicineApi on BaseApi {
  // ─── MEDICINES ────────────────────────────────────────────
  Future<List<MedicineModel>> getMedicines() async {
    final res = await dio.get('/medicines');
    final data = unwrap(res);
    return (data as List).map((e) => MedicineModel.fromJson(e)).toList();
  }

  Future<MedicineModel> storeMedicine(MedicineModel model) async {
    final res = await dio.post('/medicines', data: model.toJson());
    return MedicineModel.fromJson(unwrap(res));
  }

  Future<MedicineModel> updateMedicine(int id, MedicineModel model) async {
    final res = await dio.put('/medicines/$id', data: model.toJson());
    return MedicineModel.fromJson(unwrap(res));
  }

  Future<void> deleteMedicine(int id) async {
    await dio.delete('/medicines/$id');
  }

  // ─── MEDICINE SCHEDULES ───────────────────────────────────
  Future<List<MedicineScheduleModel>> getMedicineSchedules() async {
    final res = await dio.get('/medicine-schedules');
    final data = unwrap(res);
    return (data as List)
        .map((e) => MedicineScheduleModel.fromJson(e))
        .toList();
  }

  Future<MedicineScheduleModel> storeMedicineSchedule(
    MedicineScheduleModel model,
  ) async {
    final res = await dio.post('/medicine-schedules', data: model.toJson());
    return MedicineScheduleModel.fromJson(unwrap(res));
  }

  Future<MedicineScheduleModel> updateMedicineSchedule(
    int id,
    MedicineScheduleModel model,
  ) async {
    final res = await dio.put('/medicine-schedules/$id', data: model.toJson());
    return MedicineScheduleModel.fromJson(unwrap(res));
  }

  Future<void> deleteMedicineSchedule(int id) async {
    await dio.delete('/medicine-schedules/$id');
  }

  // ─── MEDICINE HISTORIES & DOSING ──────────────────────────
  Future<List<Map<String, dynamic>>> getTodayDoses() async {
    final res = await dio.get('/medicine-schedules/today');
    final data = unwrap(res);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<MedicineHistoryModel> takeDose({
    required int scheduleId,
    required int scheduleTimeId,
    required String status,
  }) async {
    final res = await dio.post(
      '/medicine-schedules/$scheduleId/take',
      data: {'schedule_time_id': scheduleTimeId, 'status': status},
    );
    return MedicineHistoryModel.fromJson(unwrap(res));
  }

  Future<List<MedicineHistoryModel>> getMedicineHistories() async {
    final res = await dio.get('/medicine-histories');
    final data = unwrap(res);
    return (data as List).map((e) => MedicineHistoryModel.fromJson(e)).toList();
  }

  Future<MedicineHistoryModel> storeMedicineHistory(
    MedicineHistoryModel model,
  ) async {
    final res = await dio.post('/medicine-histories', data: model.toJson());
    return MedicineHistoryModel.fromJson(unwrap(res));
  }

  Future<void> deleteMedicineHistory(int id) async {
    await dio.delete('/medicine-histories/$id');
  }
}
