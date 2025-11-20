import 'package:avankart_people/models/schedule_model.dart';
import 'package:avankart_people/models/location_point_model.dart';
import 'package:flutter/material.dart';

class CompaniesResponse {
  final int page;
  final int limit;
  final int total;
  final List<CompanyInListModel> muessises;

  CompaniesResponse({
    required this.page,
    required this.limit,
    required this.total,
    required this.muessises,
  });

  factory CompaniesResponse.fromJson(Map<String, dynamic> json) {
    return CompaniesResponse(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      muessises: json['muessises'] != null
          ? (json['muessises'] as List)
              .map((item) => CompanyInListModel.fromJson(item))
              .toList()
          : [],
    );
  }

  // Yardımcı methodlar
  bool get hasMore => (page * limit) < total;
  int get totalPages => (total / limit).ceil();
  bool get isEmpty => muessises.isEmpty;
  bool get isNotEmpty => muessises.isNotEmpty;
}

class CompanyInListModel {
  final String id;
  final String muessiseName;
  final String location;
  final LocationPoint? locationPoint;
  final List<String> cards;
  final String? profileImagePath;
  final String? xariciCoverImagePath;
  final ScheduleModel schedule;
  final double distance;
  final bool isFavorite;
  final double averageRating;
  final int totalVotes;

  CompanyInListModel({
    required this.id,
    required this.muessiseName,
    required this.location,
    this.locationPoint,
    required this.cards,
    this.profileImagePath,
    this.xariciCoverImagePath,
    required this.schedule,
    required this.distance,
    required this.isFavorite,
    required this.averageRating,
    required this.totalVotes,
  });

  factory CompanyInListModel.fromJson(Map<String, dynamic> json) {
    // Cards field'ı bazen string array, bazen object array olarak gelebilir
    List<String> cardsList = [];
    if (json['cards'] != null) {
      final cardsData = json['cards'];
      if (cardsData is List) {
        for (var card in cardsData) {
          if (card is String) {
            // Eğer string ise direkt ekle
            cardsList.add(card);
          } else if (card is Map) {
            // Eğer Map ise _id field'ını çıkar
            final cardId = card['_id'];
            if (cardId != null && cardId is String) {
              cardsList.add(cardId);
            }
          }
        }
      }
    }

    return CompanyInListModel(
      id: json['_id'] ?? '',
      muessiseName: json['muessise_name'] ?? '',
      location: json['location'] ?? '',
      locationPoint: json['location_point'] != null
          ? LocationPoint.fromJson(json['location_point'])
          : null,
      cards: cardsList,
      profileImagePath: json['profile_image_path'],
      xariciCoverImagePath: json['xarici_cover_image_path'],
      schedule: json['schedule'] != null
          ? ScheduleModel.fromJson(json['schedule'])
          : ScheduleModel.empty(),
      distance: (json['distance'] ?? 0).toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalVotes: (json['total_votes'] ?? 0) is int
          ? (json['total_votes'] ?? 0)
          : int.tryParse('${json['total_votes'] ?? 0}') ?? 0,
    );
  }

  // UI için yardımcı methodlar
  String get displayName => muessiseName;

  String get displayDistance {
    if (distance == 0) return '';
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  bool get isOpen {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final daySchedule = schedule.getDaySchedule(dayName);
    if (daySchedule == null) return false;

    return _isTimeBetween(
        currentTime, daySchedule['open']!, daySchedule['close']!);
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  bool _isTimeBetween(String current, String open, String close) {
    // Check if any time is "closed"
    if (open.toLowerCase() == 'closed' || close.toLowerCase() == 'closed') {
      return false;
    }

    final currentMinutes = _timeToMinutes(current);
    final openMinutes = _timeToMinutes(open);
    final closeMinutes = _timeToMinutes(close);

    return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
  }

  int _timeToMinutes(String time) {
    try {
      // Check if time is "closed" or invalid
      if (time.toLowerCase() == 'closed' || time.isEmpty) {
        return 0;
      }

      final parts = time.split(':');
      if (parts.length != 2) return 0;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return 0;

      return hour * 60 + minute;
    } catch (e) {
      debugPrint('[ERROR] Failed to parse time: $time, error: $e');
      return 0;
    }
  }

  // Yeni alanlar için yardımcı methodlar
  String? get coverImageUrl => xariciCoverImagePath;
  String? get profileImageUrl => profileImagePath;

  bool get hasLocationPoint => locationPoint != null;
  double? get longitude => locationPoint?.longitude;
  double? get latitude => locationPoint?.latitude;

  String get favoriteStatus => isFavorite ? 'Favorilerde' : 'Favorilere Ekle';
}

class CompaniesException implements Exception {
  final String message;
  CompaniesException(this.message);

  @override
  String toString() => message;
}
