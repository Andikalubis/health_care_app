class MealTypeModel {
  final int? id;
  final String name;

  MealTypeModel({this.id, required this.name});

  factory MealTypeModel.fromJson(Map<String, dynamic> json) {
    return MealTypeModel(id: json['id'], name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  @override
  String toString() => name;
}
