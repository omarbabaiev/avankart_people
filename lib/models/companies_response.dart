import 'package:avankart_people/models/schedule_model.dart';

class CompaniesResponse {
  final int page;
  final int limit;
  final int total;
  final List<MuessiseModel> muessises;

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
              .map((item) => MuessiseModel.fromJson(item))
              .toList()
          : [],
    );
  }
}

class MuessiseModel {
  final String id;
  final String muessiseName;
  final String location;
  final List<String> cards;
  final String? profileImagePath;
  final ScheduleModel schedule;
  final double distance;

  MuessiseModel({
    required this.id,
    required this.muessiseName,
    required this.location,
    required this.cards,
    this.profileImagePath,
    required this.schedule,
    required this.distance,
  });

  factory MuessiseModel.fromJson(Map<String, dynamic> json) {
    return MuessiseModel(
      id: json['_id'] ?? '',
      muessiseName: json['muessise_name'] ?? '',
      location: json['location'] ?? '',
      cards: json['cards'] != null ? List<String>.from(json['cards']) : [],
      profileImagePath: json['profile_image_path'],
      schedule: json['schedule'] != null
          ? ScheduleModel.fromJson(json['schedule'])
          : ScheduleModel.empty(),
      distance: (json['distance'] ?? 0).toDouble(),
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
    final currentMinutes = _timeToMinutes(current);
    final openMinutes = _timeToMinutes(open);
    final closeMinutes = _timeToMinutes(close);

    return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

class CompaniesException implements Exception {
  final String message;
  CompaniesException(this.message);

  @override
  String toString() => message;
}
