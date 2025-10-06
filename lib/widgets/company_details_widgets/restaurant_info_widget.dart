import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avankart_people/models/schedule_model.dart';

class CompanyInfoWidget extends StatelessWidget {
  final String name;
  final String description;
  final String rating;
  final ScheduleModel? schedule;

  const CompanyInfoWidget({
    Key? key,
    required this.name,
    required this.description,
    required this.rating,
    this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOpen = _calculateIsOpen();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 50, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company name with rating and open status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Image.asset(ImageAssets.starIcon,
                          color: Color(0xFFFFC107), height: 24),
                      SizedBox(width: 4),
                      Text(
                        rating,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 14),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? Color(0xFF23A26D).withOpacity(0.12)
                          : Color(0xFF000000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOpen ? 'open'.tr : 'closed'.tr,
                      style: TextStyle(
                        color: isOpen
                            ? Colors.green
                            : Theme.of(context).splashColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Theme.of(context).hintColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  bool _calculateIsOpen() {
    if (schedule == null) return false;

    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final currentDay = now.weekday; // 1 = Monday, 7 = Sunday

    WorkingHours? currentDayHours;
    switch (currentDay) {
      case 1:
        currentDayHours = schedule?.monday;
        break;
      case 2:
        currentDayHours = schedule?.tuesday;
        break;
      case 3:
        currentDayHours = schedule?.wednesday;
        break;
      case 4:
        currentDayHours = schedule?.thursday;
        break;
      case 5:
        currentDayHours = schedule?.friday;
        break;
      case 6:
        currentDayHours = schedule?.saturday;
        break;
      case 7:
        currentDayHours = schedule?.sunday;
        break;
    }

    if (currentDayHours == null ||
        currentDayHours.open == null ||
        currentDayHours.close == null) {
      return false;
    }

    // Parse opening and closing times
    final openTime = _parseTime(currentDayHours.open!);
    final closeTime = _parseTime(currentDayHours.close!);

    if (openTime == null || closeTime == null) {
      return false;
    }

    // Check if current time is between opening and closing times
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final openMinutes = openTime.hour * 60 + openTime.minute;
    final closeMinutes = closeTime.hour * 60 + closeTime.minute;

    // Handle cases where closing time is next day (e.g., 23:00 - 02:00)
    if (closeMinutes < openMinutes) {
      return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
    } else {
      return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
    }
  }

  TimeOfDay? _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }
}
