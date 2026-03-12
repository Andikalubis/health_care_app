class MedicineModel {
  final int? id;
  final String name;
  final String? description;

  MedicineModel({this.id, required this.name, this.description});

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, if (description != null) 'description': description};
  }

  @override
  String toString() => name;
}
