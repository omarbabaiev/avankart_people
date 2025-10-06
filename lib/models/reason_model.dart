class ReasonModel {
  final String id;
  final String name;
  final String text;

  ReasonModel({
    required this.id,
    required this.name,
    required this.text,
  });

  factory ReasonModel.fromJson(Map<String, dynamic> json) {
    return ReasonModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'text': text,
    };
  }
}

class ReasonsResponse {
  final bool success;
  final Map<String, List<ReasonModel>> data;
  final String? message;

  ReasonsResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory ReasonsResponse.fromJson(Map<String, dynamic> json) {
    try {
      Map<String, List<ReasonModel>> reasonsData = {};

      if (json['data'] != null) {
        final data = json['data'] as Map<String, dynamic>;

        // Her kategori için reason listesini parse et
        data.forEach((category, reasonList) {
          if (reasonList is List) {
            reasonsData[category] = reasonList
                .map((reason) => ReasonModel.fromJson(reason))
                .toList();
          }
        });
      }

      return ReasonsResponse(
        success: json['success'] ?? false,
        data: reasonsData,
        message: json['message'],
      );
    } catch (e) {
      print('[ERROR] Failed to parse ReasonsResponse: $e');
      print('[ERROR] JSON data: $json');
      return ReasonsResponse(
        success: false,
        data: {},
        message: 'Failed to parse response',
      );
    }
  }

  /// Belirli bir kategorinin reason'larını getir
  List<ReasonModel> getReasonsForCategory(String category) {
    return data[category] ?? [];
  }

  /// Tüm kategorileri getir
  List<String> get categories => data.keys.toList();

  /// Tüm reason'ları tek listede getir
  List<ReasonModel> get allReasons {
    List<ReasonModel> all = [];
    data.values.forEach((reasons) => all.addAll(reasons));
    return all;
  }
}
