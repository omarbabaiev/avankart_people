import 'package:avankart_people/models/schedule_model.dart';
import 'package:avankart_people/models/phone_model.dart';
import 'package:avankart_people/models/social_model.dart';
import 'package:avankart_people/models/authorized_person_model.dart';

class SirketIdModel {
  final AuthorizedPersonModel? authorizedPerson;
  final String? id;
  final String? activityType;
  final int? commissionPercentage;
  final int? cashbackPercentage;
  final int? companyStatus;
  final String? sirketName;
  final String? sirketCategory;
  final String? address;
  final List<String>? services;
  final String? description;
  final List<String>? cards;
  final ScheduleModel? schedule;
  final List<PhoneModel>? phone;
  final List<String>? email;
  final List<String>? website;
  final SocialModel? social;
  final String? exteriorCoverImage;
  final String? exteriorCoverImagePath;
  final String? interiorCoverImage;
  final String? interiorCoverImagePath;
  final String? profileImage;
  final String? profileImagePath;
  final String? creatorId;
  final String? rekvizitler;
  final bool? deleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? sirketId;
  final int? version;
  final double? sirketBalance;

  SirketIdModel({
    this.authorizedPerson,
    this.id,
    this.activityType,
    this.commissionPercentage,
    this.cashbackPercentage,
    this.companyStatus,
    this.sirketName,
    this.sirketCategory,
    this.address,
    this.services,
    this.description,
    this.cards,
    this.schedule,
    this.phone,
    this.email,
    this.website,
    this.social,
    this.exteriorCoverImage,
    this.exteriorCoverImagePath,
    this.interiorCoverImage,
    this.interiorCoverImagePath,
    this.profileImage,
    this.profileImagePath,
    this.creatorId,
    this.rekvizitler,
    this.deleted,
    this.createdAt,
    this.updatedAt,
    this.sirketId,
    this.version,
    this.sirketBalance,
  });

  factory SirketIdModel.fromJson(Map<String, dynamic> json) {
    return SirketIdModel(
      authorizedPerson: json['authorized_person'] != null && json['authorized_person'] is Map
          ? AuthorizedPersonModel.fromJson(json['authorized_person'])
          : null,
      id: json['_id'],
      activityType: json['activity_type'],
      commissionPercentage: json['commission_percentage'],
      cashbackPercentage: json['cashback_percentage'],
      companyStatus: json['company_status'],
      sirketName: json['sirket_name'],
      sirketCategory: json['sirket_category'],
      address: json['address'],
      services:
          json['services'] != null ? List<String>.from(json['services']) : null,
      description: json['description'],
      cards: json['cards'] != null ? List<String>.from(json['cards']) : null,
      schedule: json['schedule'] != null && json['schedule'] is Map
          ? ScheduleModel.fromJson(json['schedule'])
          : null,
      phone: json['phone'] != null && json['phone'] is List
          ? (json['phone'] as List).map((i) => PhoneModel.fromJson(i)).toList()
          : null,
      email: json['email'] != null ? List<String>.from(json['email']) : null,
      website:
          json['website'] != null ? List<String>.from(json['website']) : null,
      social:
          json['social'] != null && json['social'] is Map ? SocialModel.fromJson(json['social']) : null,
      exteriorCoverImage: json['xarici_cover_image'],
      exteriorCoverImagePath: json['xarici_cover_image_path'],
      interiorCoverImage: json['daxili_cover_image'],
      interiorCoverImagePath: json['daxili_cover_image_path'],
      profileImage: json['profile_image'],
      profileImagePath: json['profile_image_path'],
      creatorId: json['creator_id'],
      rekvizitler: json['rekvizitler'],
      deleted: json['deleted'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      sirketId: json['sirket_id'],
      version: json['__v'],
      sirketBalance: json['sirket_balance']?.toDouble(),
    );
  }
}
