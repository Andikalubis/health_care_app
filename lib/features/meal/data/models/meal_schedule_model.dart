import 'package:health_care_app/features/meal/data/models/meal_type_model.dart';
import 'package:health_care_app/features/patient/data/models/patient_data_model.dart';

class MealScheduleModel {
  final int? id;
  final int? patientId;
  final int? mealTypeId;
  final String? mealTime;
  final String? notes;
  final MealTypeModel? mealType;
  final PatientDataModel? patient;
  final String? createdAt;

  MealScheduleModel({
    this.id,
    this.patientId,
    this.mealTypeId,
    this.mealTime,
    this.notes,
    this.mealType,
    this.patient,
    this.createdAt,
  });

  factory MealScheduleModel.fromJson(Map<String, dynamic> json) {
    return MealScheduleModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      patientId: json['patient_id'] != null
          ? int.tryParse(json['patient_id'].toString())
          : null,
      mealTypeId: json['meal_type_id'] != null
          ? int.tryParse(json['meal_type_id'].toString())
          : null,
      mealTime: json['meal_time'],
      notes: json['notes'],
      mealType: json['meal_type'] != null
          ? MealTypeModel.fromJson(json['meal_type'])
          : null,
      patient: json['patient'] != null
          ? PatientDataModel.fromJson(json['patient'])
          : null,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patient_id': patientId,
      if (mealTypeId != null) 'meal_type_id': mealTypeId,
      if (mealTime != null) 'meal_time': mealTime,
      if (notes != null) 'notes': notes,
    };
  }
}
