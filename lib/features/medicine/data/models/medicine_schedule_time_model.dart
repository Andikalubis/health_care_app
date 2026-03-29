class MedicineScheduleTimeModel {
  final int? id;
  final int? scheduleId;
  final String? drinkTime;
  final String? mealRelation;
  final int? sortOrder;

  MedicineScheduleTimeModel({
    this.id,
    this.scheduleId,
    this.drinkTime,
    this.mealRelation,
    this.sortOrder,
  });

  factory MedicineScheduleTimeModel.fromJson(Map<String, dynamic> json) {
    return MedicineScheduleTimeModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      scheduleId: json['schedule_id'] != null
          ? int.tryParse(json['schedule_id'].toString())
          : null,
      drinkTime: json['drink_time'],
      mealRelation: json['meal_relation'],
      sortOrder: json['sort_order'] != null
          ? int.tryParse(json['sort_order'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (drinkTime != null) 'drink_time': drinkTime,
      if (mealRelation != null) 'meal_relation': mealRelation,
      if (sortOrder != null) 'sort_order': sortOrder,
    };
  }
}
