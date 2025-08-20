import 'user_model.dart';

class LoginResponse {
  final String token;
  final UserModel? user;
  final bool requiresOtp;

  LoginResponse(
      {required this.token, required this.user, required this.requiresOtp});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      requiresOtp: json['requiresOtp'] ?? false,
    );
  }
}
