class HealthLimitModel {
  final int? id;
  final int? healthTypeId;
  final double? warningMin;
  final double? warningMax;
  final double? dangerMin;
  final double? dangerMax;

  HealthLimitModel({
    this.id,
    this.healthTypeId,
    this.warningMin,
    this.warningMax,
    this.dangerMin,
    this.dangerMax,
  });

  factory HealthLimitModel.fromJson(Map<String, dynamic> json) {
    return HealthLimitModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      healthTypeId: json['health_type_id'] != null
          ? int.tryParse(json['health_type_id'].toString())
          : null,
      warningMin: json['warning_min'] != null
          ? double.tryParse(json['warning_min'].toString())
          : null,
      warningMax: json['warning_max'] != null
          ? double.tryParse(json['warning_max'].toString())
          : null,
      dangerMin: json['danger_min'] != null
          ? double.tryParse(json['danger_min'].toString())
          : null,
      dangerMax: json['danger_max'] != null
          ? double.tryParse(json['danger_max'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (healthTypeId != null) 'health_type_id': healthTypeId,
      if (warningMin != null) 'warning_min': warningMin,
      if (warningMax != null) 'warning_max': warningMax,
      if (dangerMin != null) 'danger_min': dangerMin,
      if (dangerMax != null) 'danger_max': dangerMax,
    };
  }
}
