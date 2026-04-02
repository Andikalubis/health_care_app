import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';

class VitalSignModel {
  final int? id;
  final int? patientId;
  final String? bloodPressure;
  final int? heartRate;
  final double? bodyTemperature;
  final int? breathingRate;
  final double? oxygenLevel;
  final String? checkTime;
  final String? createdAt;
  final PatientDataModel? patient;

  VitalSignModel({
    this.id,
    this.patientId,
    this.bloodPressure,
    this.heartRate,
    this.bodyTemperature,
    this.breathingRate,
    this.oxygenLevel,
    this.checkTime,
    this.createdAt,
    this.patient,
  });

  factory VitalSignModel.fromJson(Map<String, dynamic> json) {
    return VitalSignModel(
      id: json['id'],
      patientId: json['patient_id'],
      bloodPressure: json['blood_pressure'],
      heartRate: json['heart_rate'] != null
          ? int.tryParse(json['heart_rate'].toString())
          : null,
      bodyTemperature: json['body_temperature'] != null
          ? double.tryParse(json['body_temperature'].toString())
          : null,
      breathingRate: json['breathing_rate'] != null
          ? int.tryParse(json['breathing_rate'].toString())
          : null,
      oxygenLevel: json['oxygen_level'] != null
          ? double.tryParse(json['oxygen_level'].toString())
          : null,
      checkTime: json['check_time'],
      createdAt: json['created_at'],
      patient: json['patient'] != null
          ? PatientDataModel.fromJson(json['patient'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patient_id': patientId,
      if (bloodPressure != null) 'blood_pressure': bloodPressure,
      if (heartRate != null) 'heart_rate': heartRate,
      if (bodyTemperature != null) 'body_temperature': bodyTemperature,
      if (breathingRate != null) 'breathing_rate': breathingRate,
      if (oxygenLevel != null) 'oxygen_level': oxygenLevel,
      if (checkTime != null) 'check_time': checkTime,
    };
  }
}
