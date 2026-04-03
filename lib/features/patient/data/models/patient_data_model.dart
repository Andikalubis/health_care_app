class PatientDataModel {
  final int? id;
  final int? userId;
  final String name;
  final String gender;
  final String birthDate;
  final double? height;
  final double? weight;
  final String? bloodType;
  final String? noTlp;
  final String? telegramId;

  PatientDataModel({
    this.id,
    this.userId,
    required this.name,
    required this.gender,
    required this.birthDate,
    this.height,
    this.weight,
    this.bloodType,
    this.noTlp,
    this.telegramId,
  });

  factory PatientDataModel.fromJson(Map<String, dynamic> json) {
    return PatientDataModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      userId: json['user_id'] != null
          ? int.tryParse(json['user_id'].toString())
          : null,
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birth_date'] ?? '',
      height: json['height'] != null
          ? double.tryParse(json['height'].toString())
          : null,
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      bloodType: json['blood_type'],
      noTlp: json['no_tlp'],
      telegramId: json['telegram_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'name': name,
      'gender': gender,
      'birth_date': birthDate,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (bloodType != null) 'blood_type': bloodType,
      if (noTlp != null) 'no_tlp': noTlp,
      if (telegramId != null) 'telegram_id': telegramId,
    };
  }
}
