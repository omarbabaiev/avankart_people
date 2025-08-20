class ForgotPasswordResponse {
  final String? message;
  final String? token;

  ForgotPasswordResponse({this.message, this.token});

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message'],
      token: json['token'],
    );
  }
}
