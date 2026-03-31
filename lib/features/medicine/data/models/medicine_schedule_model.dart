import 'package:health_care_app/features/medicine/data/models/medicine_model.dart';
import 'package:health_care_app/features/medicine/data/models/medicine_schedule_time_model.dart';

class MedicineScheduleModel {
  final int? id;
  final int? patientId;
  final int? medicineId;
  final String? dosage;
  final int? signaFrequency;
  final double? dosePerIntake;
  final String? mealRelation;
  final int? qtyTotal;
  final int? qtyRemaining;
  final bool? isActive;
  final String? startDate;
  final String? endDate;
  final String? notes;
  final MedicineModel? medicine;
  final List<MedicineScheduleTimeModel>? scheduleTimes;
  final String? createdAt;

  MedicineScheduleModel({
    this.id,
    this.patientId,
    this.medicineId,
    this.dosage,
    this.signaFrequency,
    this.dosePerIntake,
    this.mealRelation,
    this.qtyTotal,
    this.qtyRemaining,
    this.isActive,
    this.startDate,
    this.endDate,
    this.notes,
    this.medicine,
    this.scheduleTimes,
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
      signaFrequency: json['signa_frequency'] != null
          ? int.tryParse(json['signa_frequency'].toString())
          : null,
      dosePerIntake: json['dose_per_intake'] != null
          ? double.tryParse(json['dose_per_intake'].toString())
          : null,
      mealRelation: json['meal_relation'],
      qtyTotal: json['qty_total'] != null
          ? int.tryParse(json['qty_total'].toString())
          : null,
      qtyRemaining: json['qty_remaining'] != null
          ? int.tryParse(json['qty_remaining'].toString())
          : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      startDate: json['start_date'],
      endDate: json['end_date'],
      notes: json['notes'],
      medicine: json['medicine'] != null
          ? MedicineModel.fromJson(json['medicine'])
          : null,
      scheduleTimes: json['schedule_times'] != null
          ? (json['schedule_times'] as List)
                .map((e) => MedicineScheduleTimeModel.fromJson(e))
                .toList()
          : null,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patient_id': patientId,
      if (medicineId != null) 'medicine_id': medicineId,
      if (dosage != null) 'dosage': dosage,
      if (signaFrequency != null) 'signa_frequency': signaFrequency,
      if (dosePerIntake != null) 'dose_per_intake': dosePerIntake,
      if (mealRelation != null) 'meal_relation': mealRelation,
      if (qtyTotal != null) 'qty_total': qtyTotal,
      if (qtyRemaining != null) 'qty_remaining': qtyRemaining,
      if (isActive != null) 'is_active': isActive,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (notes != null) 'notes': notes,
      if (scheduleTimes != null)
        'schedule_times': scheduleTimes?.map((e) => e.drinkTime).toList(),
    };
  }
}
