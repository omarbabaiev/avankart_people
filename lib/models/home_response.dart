import 'package:avankart_people/models/user_model.dart';

class HomeResponse {
  final bool? success;
  final String? message;
  final String? token;
  final UserModel? user;

  HomeResponse({
    this.success,
    this.message,
    this.token,
    this.user,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      user: json['user'] != null && json['user'] is Map ? UserModel.fromJson(json['user']) : null,
    );
  }
}
