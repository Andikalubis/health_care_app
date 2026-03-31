class MedicineHistoryModel {
  final int? id;
  final int? scheduleId;
  final int? scheduleTimeId;
  final String? scheduledFor;
  final String? takenAt;
  final String? status; // pending, taken, skipped, late
  final int? stockAfter;
  final String? createdAt;

  MedicineHistoryModel({
    this.id,
    this.scheduleId,
    this.scheduleTimeId,
    this.scheduledFor,
    this.takenAt,
    this.status,
    this.stockAfter,
    this.createdAt,
  });

  factory MedicineHistoryModel.fromJson(Map<String, dynamic> json) {
    return MedicineHistoryModel(
      id: json['id'],
      scheduleId: json['schedule_id'],
      scheduleTimeId: json['schedule_time_id'],
      scheduledFor: json['scheduled_for'],
      takenAt: json['taken_at'],
      status: json['status'],
      stockAfter: json['stock_after'] != null
          ? int.tryParse(json['stock_after'].toString())
          : null,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (scheduleTimeId != null) 'schedule_time_id': scheduleTimeId,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (takenAt != null) 'taken_at': takenAt,
      if (status != null) 'status': status,
      if (stockAfter != null) 'stock_after': stockAfter,
    };
  }
}
