class WorkingHours {
  final String? open;
  final String? close;
  final bool? isOpen;

  WorkingHours({
    this.open,
    this.close,
    this.isOpen,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      open: json['open'],
      close: json['close'],
      isOpen: json['isOpen'],
    );
  }
}

class ScheduleModel {
  final WorkingHours? monday;
  final WorkingHours? tuesday;
  final WorkingHours? wednesday;
  final WorkingHours? thursday;
  final WorkingHours? friday;
  final WorkingHours? saturday;
  final WorkingHours? sunday;

  ScheduleModel({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      monday:
          json['monday'] != null ? WorkingHours.fromJson(json['monday']) : null,
      tuesday: json['tuesday'] != null
          ? WorkingHours.fromJson(json['tuesday'])
          : null,
      wednesday: json['wednesday'] != null
          ? WorkingHours.fromJson(json['wednesday'])
          : null,
      thursday: json['thursday'] != null
          ? WorkingHours.fromJson(json['thursday'])
          : null,
      friday:
          json['friday'] != null ? WorkingHours.fromJson(json['friday']) : null,
      saturday: json['saturday'] != null
          ? WorkingHours.fromJson(json['saturday'])
          : null,
      sunday:
          json['sunday'] != null ? WorkingHours.fromJson(json['sunday']) : null,
    );
  }
}
