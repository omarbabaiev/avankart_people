import 'user_model.dart';

class RegisterResponse {
  final String? error;
  final String? message;
  final String? token;
  final UserModel? user;
  final bool? requiresOtp;

  RegisterResponse(
      {this.error, this.message, this.token, this.user, this.requiresOtp});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      error: json['error'],
      message: json['message'],
      token: json['token'],
      user: json['user'] != null && json['user'] is Map ? UserModel.fromJson(json['user']) : null,
      requiresOtp: json['requiresOtp'],
    );
  }
}
