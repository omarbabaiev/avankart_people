class SocialModel {
  final String? instagram;
  final String? facebook;
  final String? whatsapp;
  final String? telegram;

  SocialModel({
    this.instagram,
    this.facebook,
    this.whatsapp,
    this.telegram,
  });

  factory SocialModel.fromJson(Map<String, dynamic> json) {
    return SocialModel(
      instagram: json['instagram'],
      facebook: json['facebook'],
      whatsapp: json['whatsapp'],
      telegram: json['telegram'],
    );
  }
}
