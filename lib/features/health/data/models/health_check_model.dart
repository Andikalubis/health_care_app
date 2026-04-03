import 'package:health_care_app/features/health/data/models/health_type_model.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';

class HealthCheckModel {
  final int? id;
  final int? patientId;
  final int? healthTypeId;
  final double? resultValue;
  final String? status; // normal, warning, danger
  final String? notes;
  final String? checkTime;
  final String? createdAt;
  final HealthTypeModel? healthType;
  final PatientDataModel? patient;

  HealthCheckModel({
    this.id,
    this.patientId,
    this.healthTypeId,
    this.resultValue,
    this.status,
    this.notes,
    this.checkTime,
    this.createdAt,
    this.healthType,
    this.patient,
  });

  factory HealthCheckModel.fromJson(Map<String, dynamic> json) {
    return HealthCheckModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      patientId: json['patient_id'] != null
          ? int.tryParse(json['patient_id'].toString())
          : null,
      healthTypeId: json['health_type_id'] != null
          ? int.tryParse(json['health_type_id'].toString())
          : null,
      resultValue: json['result_value'] != null
          ? double.tryParse(json['result_value'].toString())
          : null,
      status: json['status'],
      notes: json['notes'],
      checkTime: json['check_time'],
      createdAt: json['created_at'],
      healthType: json['health_type'] != null
          ? HealthTypeModel.fromJson(json['health_type'])
          : null,
      patient: json['patient'] != null
          ? PatientDataModel.fromJson(json['patient'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patient_id': patientId,
      if (healthTypeId != null) 'health_type_id': healthTypeId,
      if (resultValue != null) 'result_value': resultValue,
      'status': status,
      'notes': notes,
      'check_time': checkTime,
    };
  }
}
