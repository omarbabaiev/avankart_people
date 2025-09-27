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

  factory ScheduleModel.empty() {
    return ScheduleModel();
  }

  // Get day schedule as Map for easier access
  Map<String, String>? getDaySchedule(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'monday':
        return monday != null
            ? {'open': monday!.open ?? '', 'close': monday!.close ?? ''}
            : null;
      case 'tuesday':
        return tuesday != null
            ? {'open': tuesday!.open ?? '', 'close': tuesday!.close ?? ''}
            : null;
      case 'wednesday':
        return wednesday != null
            ? {'open': wednesday!.open ?? '', 'close': wednesday!.close ?? ''}
            : null;
      case 'thursday':
        return thursday != null
            ? {'open': thursday!.open ?? '', 'close': thursday!.close ?? ''}
            : null;
      case 'friday':
        return friday != null
            ? {'open': friday!.open ?? '', 'close': friday!.close ?? ''}
            : null;
      case 'saturday':
        return saturday != null
            ? {'open': saturday!.open ?? '', 'close': saturday!.close ?? ''}
            : null;
      case 'sunday':
        return sunday != null
            ? {'open': sunday!.open ?? '', 'close': sunday!.close ?? ''}
            : null;
      default:
        return null;
    }
  }
}
