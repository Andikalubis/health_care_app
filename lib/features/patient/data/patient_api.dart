import 'package:health_care_app/core/network/base_api.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';

mixin PatientApi on BaseApi {
  Future<List<PatientDataModel>> getPatientData() async {
    final res = await dio.get('/patient-data');
    final data = unwrap(res);
    if (data is List) {
      return data.map((e) => PatientDataModel.fromJson(e)).toList();
    }
    return [PatientDataModel.fromJson(data)];
  }

  Future<PatientDataModel> storePatientData(PatientDataModel model) async {
    final res = await dio.post('/patient-data', data: model.toJson());
    return PatientDataModel.fromJson(unwrap(res));
  }

  Future<PatientDataModel> updatePatientData(
    int id,
    PatientDataModel model,
  ) async {
    final res = await dio.put('/patient-data/$id', data: model.toJson());
    return PatientDataModel.fromJson(unwrap(res));
  }

  Future<void> deletePatientData(int id) async {
    await dio.delete('/patient-data/$id');
  }
}
