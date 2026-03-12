class HealthTypeModel {
  final int? id;
  final String name;
  final String? unit;
  final double? normalMin;
  final double? normalMax;
  final String? description;

  HealthTypeModel({
    this.id,
    required this.name,
    this.unit,
    this.normalMin,
    this.normalMax,
    this.description,
  });

  factory HealthTypeModel.fromJson(Map<String, dynamic> json) {
    return HealthTypeModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name'] ?? '',
      unit: json['unit'],
      description: json['description'],
      normalMin: json['normal_min'] != null
          ? double.tryParse(json['normal_min'].toString())
          : null,
      normalMax: json['normal_max'] != null
          ? double.tryParse(json['normal_max'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (unit != null) 'unit': unit,
      if (normalMin != null) 'normal_min': normalMin,
      if (normalMax != null) 'normal_max': normalMax,
      if (description != null) 'description': description,
    };
  }

  @override
  String toString() => name;
}
