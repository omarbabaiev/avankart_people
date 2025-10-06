import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/models/schedule_model.dart';
import 'package:get/get.dart';

class CompanyWorkingHoursWidget extends StatelessWidget {
  final ScheduleModel? schedule;

  const CompanyWorkingHoursWidget({
    Key? key,
    this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 12,
          ),
          Text(
            "working_hours".tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Theme.of(context).hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildDayCircle(
                  "monday".tr, _isDayOpen(schedule?.monday), context),
              _buildDayCircle(
                  "tuesday".tr, _isDayOpen(schedule?.tuesday), context),
              _buildDayCircle(
                  "wednesday".tr, _isDayOpen(schedule?.wednesday), context),
              _buildDayCircle(
                  "thursday".tr, _isDayOpen(schedule?.thursday), context),
              _buildDayCircle(
                  "friday".tr, _isDayOpen(schedule?.friday), context),
              _buildDayCircle(
                  "saturday".tr, _isDayOpen(schedule?.saturday), context),
              _buildDayCircle(
                  "sunday".tr, _isDayOpen(schedule?.sunday), context),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _getWorkingHoursText(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCircle(String day, bool isOpen, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 6),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(ImageAssets.dayBackContainer)),
        shape: BoxShape.circle,
        color: isOpen ? AppTheme.focusColor : Colors.grey.shade300,
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: isOpen
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  bool _isDayOpen(WorkingHours? workingHours) {
    if (workingHours == null) return false;

    // Check if the day is closed
    if (workingHours.open == "closed" || workingHours.close == "closed") {
      return false;
    }

    // If open and close times are provided, consider it open
    if (workingHours.open != null && workingHours.close != null) {
      return true;
    }

    return workingHours.isOpen ?? false;
  }

  String _getWorkingHoursText() {
    if (schedule == null) return 'working_hours_not_available'.tr;

    // Get current day's working hours
    final now = DateTime.now();
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
      return 'working_hours_not_available'.tr;
    }

    // Check if the day is closed
    if (currentDayHours.open == "closed" || currentDayHours.close == "closed") {
      return 'closed'.tr;
    }

    return '${currentDayHours.open} - ${currentDayHours.close}';
  }
}
