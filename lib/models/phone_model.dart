class PhoneModel {
  final String? number;
  final String? prefix;
  final String? id;

  PhoneModel({
    this.number,
    this.prefix,
    this.id,
  });

  factory PhoneModel.fromJson(Map<String, dynamic> json) {
    return PhoneModel(
      number: json['number'],
      prefix: json['prefix'],
      id: json['_id'],
    );
  }
}
