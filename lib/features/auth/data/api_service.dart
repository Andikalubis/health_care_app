import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_care_app/features/auth/data/models/auth_response.dart';
import 'package:health_care_app/features/auth/data/token_interceptor.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';
import 'package:health_care_app/features/health/data/models/vital_sign_model.dart';
import 'package:health_care_app/features/health/data/models/health_type_model.dart';
import 'package:health_care_app/features/health/data/models/health_check_model.dart';
import 'package:health_care_app/features/health/data/models/health_limit_model.dart';
import 'package:health_care_app/features/health/data/models/health_alert_model.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_model.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_schedule_model.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_history_model.dart';
import 'package:health_care_app/features/meal/data/models/meal_type_model.dart';
import 'package:health_care_app/features/meal/data/models/meal_schedule_model.dart';
import 'package:health_care_app/features/notification/data/models/notification_model.dart';
import 'package:chucker_flutter/chucker_flutter.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://192.168.112.146:8000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  ApiService() {
    _dio.interceptors.addAll([ChuckerDioInterceptor(), TokenInterceptor(_dio)]);
  }

  // ─── Helpers ───────────────────────────────────────────────
  dynamic _unwrap(Response res) {
    if (res.data is Map && res.data.containsKey('data')) {
      return res.data['data'];
    }
    return res.data;
  }

  Never _handleError(DioException e, String fallback) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      String message = fallback;
      if (data is Map) {
        message = data['message'] ?? fallback;
      } else if (data is String) {
        message = data;
      }
      throw Exception(message);
    }
    throw e;
  }

  // ─── AUTH ──────────────────────────────────────────────────
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', authResponse.accessToken);
        await prefs.setString('user_name', authResponse.user.name);
        await prefs.setInt('user_id', authResponse.user.id);
        if (authResponse.refreshToken != null) {
          await prefs.setString('refresh_token', authResponse.refreshToken!);
        }
        return authResponse;
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleError(e, 'Login failed');
    }
  }

  Future<AuthResponse> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', authResponse.accessToken);
        await prefs.setString('user_name', authResponse.user.name);
        await prefs.setInt('user_id', authResponse.user.id);
        if (authResponse.refreshToken != null) {
          await prefs.setString('refresh_token', authResponse.refreshToken!);
        }
        return authResponse;
      } else {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleError(e, 'Registration failed');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
  }

  // ─── PATIENT DATA ──────────────────────────────────────────
  Future<List<PatientDataModel>> getPatientData() async {
    final res = await _dio.get('/patient-data');
    final data = _unwrap(res);
    if (data is List) {
      return data.map((e) => PatientDataModel.fromJson(e)).toList();
    }
    return [PatientDataModel.fromJson(data)];
  }

  Future<PatientDataModel> storePatientData(PatientDataModel model) async {
    final res = await _dio.post('/patient-data', data: model.toJson());
    return PatientDataModel.fromJson(_unwrap(res));
  }

  Future<PatientDataModel> updatePatientData(
    int id,
    PatientDataModel model,
  ) async {
    final res = await _dio.put('/patient-data/$id', data: model.toJson());
    return PatientDataModel.fromJson(_unwrap(res));
  }

  Future<void> deletePatientData(int id) async {
    await _dio.delete('/patient-data/$id');
  }

  // ─── VITAL SIGNS ──────────────────────────────────────────
  Future<List<VitalSignModel>> getVitalSigns() async {
    final res = await _dio.get('/vital-signs');
    final data = _unwrap(res);
    return (data as List).map((e) => VitalSignModel.fromJson(e)).toList();
  }

  Future<VitalSignModel> storeVitalSign(VitalSignModel model) async {
    final res = await _dio.post('/vital-signs', data: model.toJson());
    return VitalSignModel.fromJson(_unwrap(res));
  }

  Future<VitalSignModel> updateVitalSign(int id, VitalSignModel model) async {
    final res = await _dio.put('/vital-signs/$id', data: model.toJson());
    return VitalSignModel.fromJson(_unwrap(res));
  }

  Future<void> deleteVitalSign(int id) async {
    await _dio.delete('/vital-signs/$id');
  }

  // ─── HEALTH TYPES ─────────────────────────────────────────
  Future<List<HealthTypeModel>> getHealthTypes() async {
    final res = await _dio.get('/health-types');
    final data = _unwrap(res);
    return (data as List).map((e) => HealthTypeModel.fromJson(e)).toList();
  }

  Future<HealthTypeModel> storeHealthType(HealthTypeModel model) async {
    final res = await _dio.post('/health-types', data: model.toJson());
    return HealthTypeModel.fromJson(_unwrap(res));
  }

  Future<HealthTypeModel> updateHealthType(
    int id,
    HealthTypeModel model,
  ) async {
    final res = await _dio.put('/health-types/$id', data: model.toJson());
    return HealthTypeModel.fromJson(_unwrap(res));
  }

  Future<void> deleteHealthType(int id) async {
    await _dio.delete('/health-types/$id');
  }

  // ─── HEALTH CHECKS ────────────────────────────────────────
  Future<List<HealthCheckModel>> getHealthChecks() async {
    final res = await _dio.get('/health-checks');
    final data = _unwrap(res);
    return (data as List).map((e) => HealthCheckModel.fromJson(e)).toList();
  }

  Future<HealthCheckModel> storeHealthCheck(HealthCheckModel model) async {
    final res = await _dio.post('/health-checks', data: model.toJson());
    return HealthCheckModel.fromJson(_unwrap(res));
  }

  Future<HealthCheckModel> updateHealthCheck(
    int id,
    HealthCheckModel model,
  ) async {
    final res = await _dio.put('/health-checks/$id', data: model.toJson());
    return HealthCheckModel.fromJson(_unwrap(res));
  }

  Future<void> deleteHealthCheck(int id) async {
    await _dio.delete('/health-checks/$id');
  }

  // ─── HEALTH LIMITS ────────────────────────────────────────
  Future<List<HealthLimitModel>> getHealthLimits() async {
    final res = await _dio.get('/health-limits');
    final data = _unwrap(res);
    return (data as List).map((e) => HealthLimitModel.fromJson(e)).toList();
  }

  Future<HealthLimitModel> storeHealthLimit(HealthLimitModel model) async {
    final res = await _dio.post('/health-limits', data: model.toJson());
    return HealthLimitModel.fromJson(_unwrap(res));
  }

  Future<void> deleteHealthLimit(int id) async {
    await _dio.delete('/health-limits/$id');
  }

  // ─── HEALTH ALERTS ────────────────────────────────────────
  Future<List<HealthAlertModel>> getHealthAlerts() async {
    final res = await _dio.get('/health-alerts');
    final data = _unwrap(res);
    return (data as List).map((e) => HealthAlertModel.fromJson(e)).toList();
  }

  Future<void> deleteHealthAlert(int id) async {
    await _dio.delete('/health-alerts/$id');
  }

  // ─── MEDICINES ────────────────────────────────────────────
  Future<List<MedicineModel>> getMedicines() async {
    final res = await _dio.get('/medicines');
    final data = _unwrap(res);
    return (data as List).map((e) => MedicineModel.fromJson(e)).toList();
  }

  Future<MedicineModel> storeMedicine(MedicineModel model) async {
    final res = await _dio.post('/medicines', data: model.toJson());
    return MedicineModel.fromJson(_unwrap(res));
  }

  Future<MedicineModel> updateMedicine(int id, MedicineModel model) async {
    final res = await _dio.put('/medicines/$id', data: model.toJson());
    return MedicineModel.fromJson(_unwrap(res));
  }

  Future<void> deleteMedicine(int id) async {
    await _dio.delete('/medicines/$id');
  }

  // ─── MEDICINE SCHEDULES ───────────────────────────────────
  Future<List<MedicineScheduleModel>> getMedicineSchedules() async {
    final res = await _dio.get('/medicine-schedules');
    final data = _unwrap(res);
    return (data as List)
        .map((e) => MedicineScheduleModel.fromJson(e))
        .toList();
  }

  Future<MedicineScheduleModel> storeMedicineSchedule(
    MedicineScheduleModel model,
  ) async {
    final res = await _dio.post('/medicine-schedules', data: model.toJson());
    return MedicineScheduleModel.fromJson(_unwrap(res));
  }

  Future<MedicineScheduleModel> updateMedicineSchedule(
    int id,
    MedicineScheduleModel model,
  ) async {
    final res = await _dio.put('/medicine-schedules/$id', data: model.toJson());
    return MedicineScheduleModel.fromJson(_unwrap(res));
  }

  Future<void> deleteMedicineSchedule(int id) async {
    await _dio.delete('/medicine-schedules/$id');
  }

  // ─── MEDICINE HISTORIES ───────────────────────────────────
  Future<List<MedicineHistoryModel>> getMedicineHistories() async {
    final res = await _dio.get('/medicine-histories');
    final data = _unwrap(res);
    return (data as List).map((e) => MedicineHistoryModel.fromJson(e)).toList();
  }

  Future<MedicineHistoryModel> storeMedicineHistory(
    MedicineHistoryModel model,
  ) async {
    final res = await _dio.post('/medicine-histories', data: model.toJson());
    return MedicineHistoryModel.fromJson(_unwrap(res));
  }

  Future<void> deleteMedicineHistory(int id) async {
    await _dio.delete('/medicine-histories/$id');
  }

  // ─── MEAL TYPES ───────────────────────────────────────────
  Future<List<MealTypeModel>> getMealTypes() async {
    final res = await _dio.get('/meal-types');
    final data = _unwrap(res);
    return (data as List).map((e) => MealTypeModel.fromJson(e)).toList();
  }

  Future<MealTypeModel> storeMealType(MealTypeModel model) async {
    final res = await _dio.post('/meal-types', data: model.toJson());
    return MealTypeModel.fromJson(_unwrap(res));
  }

  Future<void> deleteMealType(int id) async {
    await _dio.delete('/meal-types/$id');
  }

  // ─── MEAL SCHEDULES ───────────────────────────────────────
  Future<List<MealScheduleModel>> getMealSchedules() async {
    final res = await _dio.get('/meal-schedules');
    final data = _unwrap(res);
    return (data as List).map((e) => MealScheduleModel.fromJson(e)).toList();
  }

  Future<MealScheduleModel> storeMealSchedule(MealScheduleModel model) async {
    final res = await _dio.post('/meal-schedules', data: model.toJson());
    return MealScheduleModel.fromJson(_unwrap(res));
  }

  Future<MealScheduleModel> updateMealSchedule(
    int id,
    MealScheduleModel model,
  ) async {
    final res = await _dio.put('/meal-schedules/$id', data: model.toJson());
    return MealScheduleModel.fromJson(_unwrap(res));
  }

  Future<void> deleteMealSchedule(int id) async {
    await _dio.delete('/meal-schedules/$id');
  }

  // ─── NOTIFICATIONS ────────────────────────────────────────
  Future<List<NotificationModel>> getNotifications() async {
    final res = await _dio.get('/notifications');
    final data = _unwrap(res);
    return (data as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> deleteNotification(int id) async {
    await _dio.delete('/notifications/$id');
  }
}
