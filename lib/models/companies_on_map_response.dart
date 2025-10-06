import 'package:avankart_people/models/location_point_model.dart';

class CompaniesOnMapResponse {
  final bool success;
  final List<CompanyOnMapModel> data;
  final bool cached;

  CompaniesOnMapResponse({
    required this.success,
    required this.data,
    required this.cached,
  });

  factory CompaniesOnMapResponse.fromJson(Map<String, dynamic> json) {
    return CompaniesOnMapResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => CompanyOnMapModel.fromJson(item))
              .toList()
          : [],
      cached: json['cached'] ?? false,
    );
  }

  // Yardımcı methodlar
  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
}

class CompanyOnMapModel {
  final String id;
  final LocationPoint? locationPoint;
  final String? profileImagePath;

  CompanyOnMapModel({
    required this.id,
    this.locationPoint,
    this.profileImagePath,
  });

  factory CompanyOnMapModel.fromJson(Map<String, dynamic> json) {
    return CompanyOnMapModel(
      id: json['_id'] ?? '',
      locationPoint: json['location_point'] != null
          ? LocationPoint.fromJson(json['location_point'])
          : null,
      profileImagePath: json['profile_image_path'],
    );
  }

  // Yardımcı methodlar
  bool get hasLocationPoint => locationPoint != null;
  double? get longitude => locationPoint?.longitude;
  double? get latitude => locationPoint?.latitude;
  bool get hasProfileImage =>
      profileImagePath != null && profileImagePath!.isNotEmpty;
}

class CompaniesOnMapException implements Exception {
  final String message;
  CompaniesOnMapException(this.message);

  @override
  String toString() => message;
}
