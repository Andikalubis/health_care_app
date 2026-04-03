class TelegramUserModel {
  final int? id;
  final int? userId;
  final String? telegramChatId;
  final String? telegramUsername;
  final String? createdAt;

  TelegramUserModel({
    this.id,
    this.userId,
    this.telegramChatId,
    this.telegramUsername,
    this.createdAt,
  });

  factory TelegramUserModel.fromJson(Map<String, dynamic> json) {
    return TelegramUserModel(
      id: json['id'],
      userId: json['user_id'],
      telegramChatId: json['telegram_chat_id'],
      telegramUsername: json['telegram_username'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      if (telegramChatId != null) 'telegram_chat_id': telegramChatId,
      if (telegramUsername != null) 'telegram_username': telegramUsername,
    };
  }
}
