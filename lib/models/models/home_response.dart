import 'package:avankart_people/models/user_model.dart';

class HomeResponse {
  final bool? success;
  final String? message;
  final String? token;
  final UserModel? user;
  final dynamic sadiq; // Bu alan null olabiliyor

  HomeResponse({
    this.success,
    this.message,
    this.token,
    this.user,
    this.sadiq,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      sadiq: json['sadiq'],
    );
  }
}
