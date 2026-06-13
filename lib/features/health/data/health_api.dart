import 'package:health_care_app/core/network/base_api.dart';
import 'package:health_care_app/features/health/data/models/vital_sign_model.dart';
import 'package:health_care_app/features/health/data/models/health_type_model.dart';
import 'package:health_care_app/features/health/data/models/health_check_model.dart';
import 'package:health_care_app/features/health/data/models/health_limit_model.dart';

mixin HealthApi on BaseApi {
  // ─── VITAL SIGNS ──────────────────────────────────────────
  Future<List<VitalSignModel>> getVitalSigns() async {
    final res = await dio.get('/vital-signs');
    final data = unwrap(res);
    return (data as List).map((e) => VitalSignModel.fromJson(e)).toList();
  }

  Future<VitalSignModel> storeVitalSign(VitalSignModel model) async {
    return safeApiCall(() async {
      final res = await dio.post('/vital-signs', data: model.toJson());
      return VitalSignModel.fromJson(unwrap(res));
    }, 'Gagal menyimpan tanda vital');
  }

  Future<VitalSignModel> updateVitalSign(int id, VitalSignModel model) async {
    return safeApiCall(() async {
      final res = await dio.put('/vital-signs/$id', data: model.toJson());
      return VitalSignModel.fromJson(unwrap(res));
    }, 'Gagal memperbarui tanda vital');
  }

  Future<void> deleteVitalSign(int id) async {
    await dio.delete('/vital-signs/$id');
  }

  // ─── HEALTH TYPES ─────────────────────────────────────────
  Future<List<HealthTypeModel>> getHealthTypes() async {
    final res = await dio.get('/health-types');
    final data = unwrap(res);
    return (data as List).map((e) => HealthTypeModel.fromJson(e)).toList();
  }

  Future<HealthTypeModel> storeHealthType(HealthTypeModel model) async {
    return safeApiCall(() async {
      final res = await dio.post('/health-types', data: model.toJson());
      return HealthTypeModel.fromJson(unwrap(res));
    }, 'Gagal menyimpan tipe kesehatan');
  }

  Future<HealthTypeModel> updateHealthType(
    int id,
    HealthTypeModel model,
  ) async {
    return safeApiCall(() async {
      final res = await dio.put('/health-types/$id', data: model.toJson());
      return HealthTypeModel.fromJson(unwrap(res));
    }, 'Gagal memperbarui tipe kesehatan');
  }

  Future<void> deleteHealthType(int id) async {
    await dio.delete('/health-types/$id');
  }

  // ─── HEALTH CHECKS ────────────────────────────────────────
  Future<List<HealthCheckModel>> getHealthChecks() async {
    final res = await dio.get('/health-checks');
    final data = unwrap(res);
    return (data as List).map((e) => HealthCheckModel.fromJson(e)).toList();
  }

  Future<HealthCheckModel> storeHealthCheck(HealthCheckModel model) async {
    return safeApiCall(() async {
      final res = await dio.post('/health-checks', data: model.toJson());
      return HealthCheckModel.fromJson(unwrap(res));
    }, 'Gagal menyimpan pemeriksaan kesehatan');
  }

  Future<HealthCheckModel> updateHealthCheck(
    int id,
    HealthCheckModel model,
  ) async {
    return safeApiCall(() async {
      final res = await dio.put('/health-checks/$id', data: model.toJson());
      return HealthCheckModel.fromJson(unwrap(res));
    }, 'Gagal memperbarui pemeriksaan kesehatan');
  }

  Future<void> deleteHealthCheck(int id) async {
    await dio.delete('/health-checks/$id');
  }

  // ─── HEALTH LIMITS ────────────────────────────────────────
  Future<List<HealthLimitModel>> getHealthLimits() async {
    final res = await dio.get('/health-limits');
    final data = unwrap(res);
    return (data as List).map((e) => HealthLimitModel.fromJson(e)).toList();
  }

  Future<HealthLimitModel> storeHealthLimit(HealthLimitModel model) async {
    return safeApiCall(() async {
      final res = await dio.post('/health-limits', data: model.toJson());
      return HealthLimitModel.fromJson(unwrap(res));
    }, 'Gagal menyimpan batas kesehatan');
  }

  Future<HealthLimitModel> updateHealthLimit(
    int id,
    HealthLimitModel model,
  ) async {
    return safeApiCall(() async {
      final res = await dio.put('/health-limits/$id', data: model.toJson());
      return HealthLimitModel.fromJson(unwrap(res));
    }, 'Gagal memperbarui batas kesehatan');
  }

  Future<void> deleteHealthLimit(int id) async {
    await dio.delete('/health-limits/$id');
  }
}
