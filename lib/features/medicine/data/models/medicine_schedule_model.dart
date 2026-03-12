import 'package:health_care_app/features/medicine/data/models/medicine_model.dart';

class MedicineScheduleModel {
  final int? id;
  final int? patientId;
  final int? medicineId;
  final String? dosage;
  final String? drinkTime;
  final String? startDate;
  final String? endDate;
  final String? notes;
  final MedicineModel? medicine;
  final String? createdAt;

  MedicineScheduleModel({
    this.id,
    this.patientId,
    this.medicineId,
    this.dosage,
    this.drinkTime,
    this.startDate,
    this.endDate,
    this.notes,
    this.medicine,
    this.createdAt,
  });

  factory MedicineScheduleModel.fromJson(Map<String, dynamic> json) {
    return MedicineScheduleModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      patientId: json['patient_id'] != null
          ? int.tryParse(json['patient_id'].toString())
          : null,
      medicineId: json['medicine_id'] != null
          ? int.tryParse(json['medicine_id'].toString())
          : null,
      dosage: json['dosage'],
      drinkTime: json['drink_time'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      notes: json['notes'],
      medicine: json['medicine'] != null
          ? MedicineModel.fromJson(json['medicine'])
          : null,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patient_id': patientId,
      if (medicineId != null) 'medicine_id': medicineId,
      if (dosage != null) 'dosage': dosage,
      if (drinkTime != null) 'drink_time': drinkTime,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (notes != null) 'notes': notes,
    };
  }
}
