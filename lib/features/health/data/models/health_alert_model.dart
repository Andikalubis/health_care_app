import 'package:health_care_app/features/health/data/models/health_check_model.dart';

class HealthAlertModel {
  final int? id;
  final int? healthCheckId;
  final String? alertLevel; // warning, danger
  final String? message;
  final String? sentStatus;
  final String? createdAt;
  final HealthCheckModel? healthCheck;

  HealthAlertModel({
    this.id,
    this.healthCheckId,
    this.alertLevel,
    this.message,
    this.sentStatus,
    this.createdAt,
    this.healthCheck,
  });

  factory HealthAlertModel.fromJson(Map<String, dynamic> json) {
    return HealthAlertModel(
      id: json['id'],
      healthCheckId: json['health_check_id'],
      alertLevel: json['alert_level'],
      message: json['message'],
      sentStatus: json['sent_status']?.toString(),
      createdAt: json['created_at'],
      healthCheck: json['health_check'] != null
          ? HealthCheckModel.fromJson(json['health_check'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (healthCheckId != null) 'health_check_id': healthCheckId,
      if (alertLevel != null) 'alert_level': alertLevel,
      if (message != null) 'message': message,
      if (sentStatus != null) 'sent_status': sentStatus,
    };
  }
}
