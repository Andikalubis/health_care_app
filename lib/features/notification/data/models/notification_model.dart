class NotificationModel {
  final int? id;
  final int? userId;
  final String? title;
  final String? message;
  final String? notificationType;
  final String? sendTime;
  final String? createdAt;

  NotificationModel({
    this.id,
    this.userId,
    this.title,
    this.message,
    this.notificationType,
    this.sendTime,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      notificationType: json['notification_type'],
      sendTime: json['send_time'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (notificationType != null) 'notification_type': notificationType,
      if (sendTime != null) 'send_time': sendTime,
    };
  }
}
