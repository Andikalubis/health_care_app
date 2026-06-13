class MedicineModel {
  final int? id;
  final String name;
  final String? description;
  final String unit;

  MedicineModel({
    this.id,
    required this.name,
    this.description,
    this.unit = 'tablet',
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      unit: json['unit'] ?? 'tablet',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'unit': unit,
    };
  }

  @override
  String toString() => name;
}
