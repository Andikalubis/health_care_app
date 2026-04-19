import 'user_model.dart';

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final UserModel user;
  final bool isTelegram;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.user,
    required this.isTelegram,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      user: UserModel.fromJson(json['user']),
      isTelegram: json['is_telegram'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'user': user.toJson(),
      'is_telegram': isTelegram,
    };
  }
}
