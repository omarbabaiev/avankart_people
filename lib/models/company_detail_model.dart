import 'package:avankart_people/models/location_point_model.dart';
import 'package:avankart_people/models/phone_model.dart';
import 'package:avankart_people/models/schedule_model.dart';
import 'package:avankart_people/models/social_model.dart';

class CompanyDetailResponse {
  final bool success;
  final String message;
  final CompanyDetailData data;

  CompanyDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CompanyDetailResponse.fromJson(Map<String, dynamic> json) {
    return CompanyDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CompanyDetailData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class CompanyDetailData {
  final CompanyDetail responseData;

  CompanyDetailData({
    required this.responseData,
  });

  factory CompanyDetailData.fromJson(Map<String, dynamic> json) {
    return CompanyDetailData(
      responseData: CompanyDetail.fromJson(json['responseData'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responseData': responseData.toJson(),
    };
  }
}

class CompanyDetail {
  final String id;
  final String muessiseId;
  final String activityType;
  final String muessiseName;
  final double? lat;
  final double? lng;
  final LocationPoint? locationPoint;
  final String address;
  final String? profileImagePath;
  final String? daxiliCoverImagePath;
  final String? description;
  final List<String> services;
  final List<dynamic> cards;
  final ScheduleModel schedule;
  final List<PhoneModel> phone;
  final List<String> email;
  final SocialModel? social;
  final List<String> website;
  final double? distance;
  final bool isFavorite;
  final double? averageRating;
  final int? totalVotes;

  CompanyDetail({
    required this.id,
    required this.muessiseId,
    required this.activityType,
    required this.muessiseName,
    this.lat,
    this.lng,
    this.locationPoint,
    required this.address,
    this.profileImagePath,
    this.daxiliCoverImagePath,
    this.description,
    required this.services,
    required this.cards,
    required this.schedule,
    required this.phone,
    required this.email,
    this.social,
    required this.website,
    this.distance,
    required this.isFavorite,
    this.averageRating,
    this.totalVotes,
  });

  factory CompanyDetail.fromJson(Map<String, dynamic> json) {
    return CompanyDetail(
      id: json['_id'] ?? '',
      muessiseId: json['muessise_id'] ?? '',
      activityType: json['activity_type'] ?? '',
      muessiseName: json['muessise_name'] ?? '',
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      locationPoint: json['location_point'] != null
          ? LocationPoint.fromJson(json['location_point'])
          : null,
      address: json['address'] ?? '',
      profileImagePath: json['profile_image_path'],
      daxiliCoverImagePath: json['daxili_cover_image_path'],
      description: json['description'],
      services:
          json['services'] != null ? List<String>.from(json['services']) : [],
      cards: json['cards'] ?? [],
      schedule: ScheduleModel.fromJson(json['schedule'] ?? {}),
      phone: json['phone'] != null
          ? (json['phone'] as List).map((e) => PhoneModel.fromJson(e)).toList()
          : [],
      email: json['email'] != null ? List<String>.from(json['email']) : [],
      social:
          json['social'] != null ? SocialModel.fromJson(json['social']) : null,
      website:
          json['website'] != null ? List<String>.from(json['website']) : [],
      distance: json['distance']?.toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      averageRating: json['average_rating']?.toDouble(),
      totalVotes: json['total_votes']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'muessise_id': muessiseId,
      'activity_type': activityType,
      'muessise_name': muessiseName,
      'lat': lat,
      'lng': lng,
      'location_point': locationPoint?.toJson(),
      'address': address,
      'profile_image_path': profileImagePath,
      'daxili_cover_image_path': daxiliCoverImagePath,
      'description': description,
      'services': services,
      'cards': cards,
      'schedule': schedule, // ScheduleModel doesn't have toJson method
      'phone': phone, // PhoneModel doesn't have toJson method
      'email': email,
      'social': social, // SocialModel doesn't have toJson method
      'website': website,
      'distance': distance,
      'isFavorite': isFavorite,
      'average_rating': averageRating,
      'total_votes': totalVotes,
    };
  }

  // Helper getters
  String get coverImageUrl => daxiliCoverImagePath ?? 'assets/images/image.png';
  String get profileImageUrl => profileImagePath ?? 'assets/images/image.png';
  String get displayDistance =>
      distance != null ? '${distance!.toStringAsFixed(1)} km' : '0.0 km';
  bool get hasLocationPoint => locationPoint != null;
  double? get longitude => locationPoint?.longitude;
  double? get latitude => locationPoint?.latitude;
  String get primaryPhone =>
      phone.isNotEmpty ? '${phone.first.prefix} ${phone.first.number}' : '';
  String get primaryEmail => email.isNotEmpty ? email.first : '';
  String get primaryWebsite => website.isNotEmpty ? website.first : '';
}
