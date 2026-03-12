class MedicineHistoryModel {
  final int? id;
  final int? scheduleId;
  final String? takenTime;
  final String? status; // taken, skipped
  final String? createdAt;

  MedicineHistoryModel({
    this.id,
    this.scheduleId,
    this.takenTime,
    this.status,
    this.createdAt,
  });

  factory MedicineHistoryModel.fromJson(Map<String, dynamic> json) {
    return MedicineHistoryModel(
      id: json['id'],
      scheduleId: json['schedule_id'],
      takenTime: json['taken_time'],
      status: json['status'],
      createdAt: json['created_at'],
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
