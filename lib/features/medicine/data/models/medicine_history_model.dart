import 'package:health_care_app/features/medicine/data/models/medicine_schedule_model.dart';

class MedicineHistoryModel {
  final int? id;
  final int? scheduleId;
  final String? takenTime;
  final String? status; // consumed, skipped, late
  final String? createdAt;
  final MedicineScheduleModel? medicineSchedule;

  MedicineHistoryModel({
    this.id,
    this.scheduleId,
    this.takenTime,
    this.status,
    this.createdAt,
    this.medicineSchedule,
  });

  factory MedicineHistoryModel.fromJson(Map<String, dynamic> json) {
    return MedicineHistoryModel(
      id: json['id'],
      scheduleId: json['schedule_id'],
      takenTime: json['taken_time'],
      status: json['status'],
      createdAt: json['created_at'],
      medicineSchedule: json['medicine_schedule'] != null
          ? MedicineScheduleModel.fromJson(json['medicine_schedule'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (takenTime != null) 'taken_time': takenTime,
      if (status != null) 'status': status,
    };
  }
}
