class HealthAlertModel {
  final int? id;
  final int? healthCheckId;
  final String? alertLevel; // warning, danger
  final String? message;
  final String? sentStatus;
  final String? createdAt;

  HealthAlertModel({
    this.id,
    this.healthCheckId,
    this.alertLevel,
    this.message,
    this.sentStatus,
    this.createdAt,
  });

  factory HealthAlertModel.fromJson(Map<String, dynamic> json) {
    return HealthAlertModel(
      id: json['id'],
      healthCheckId: json['health_check_id'],
      alertLevel: json['alert_level'],
      message: json['message'],
      sentStatus: json['sent_status'],
      createdAt: json['created_at'],
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
