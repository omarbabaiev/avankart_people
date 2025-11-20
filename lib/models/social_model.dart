class SocialModel {
  final String? instagram;
  final String? facebook;
  final String? whatsapp;
  final String? telegram;
  final String? linkedin;

  SocialModel({
    this.instagram,
    this.facebook,
    this.whatsapp,
    this.telegram,
    this.linkedin,
  });

  factory SocialModel.fromJson(Map<String, dynamic> json) {
    return SocialModel(
      instagram: json['instagram'],
      facebook: json['facebook'],
      whatsapp: json['whatsapp'],
      telegram: json['telegram'],
      linkedin: json['linkedin'],
    );
  }
}
