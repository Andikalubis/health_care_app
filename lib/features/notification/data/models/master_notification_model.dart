class MasterNotificationModel {
  final int? id;
  final String? title;
  final String? message;
  final String? notificationType;
  final String? createdAt;
  final String? updatedAt;

  MasterNotificationModel({
    this.id,
    this.title,
    this.message,
    this.notificationType,
    this.createdAt,
    this.updatedAt,
  });

  factory MasterNotificationModel.fromJson(Map<String, dynamic> json) {
    return MasterNotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      notificationType: json['notification_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (notificationType != null) 'notification_type': notificationType,
    };
  }
}
