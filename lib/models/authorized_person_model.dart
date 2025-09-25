class AuthorizedPersonModel {
  final String? name;
  final String? gender;
  final String? duty;
  final String? phoneSuffix;
  final int? phone;
  final String? email;

  AuthorizedPersonModel({
    this.name,
    this.gender,
    this.duty,
    this.phoneSuffix,
    this.phone,
    this.email,
  });

  factory AuthorizedPersonModel.fromJson(Map<String, dynamic> json) {
    return AuthorizedPersonModel(
      name: json['name'],
      gender: json['gender'],
      duty: json['duty'],
      phoneSuffix: json['phone_suffix'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}
