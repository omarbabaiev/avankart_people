import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:avankart_people/utils/app_theme.dart';

class RestaurantWorkingHoursWidget extends StatelessWidget {
  const RestaurantWorkingHoursWidget({Key? key}) : super(key: key);

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
            "İş günləri",
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
              _buildDayCircle("B.E", true, context),
              _buildDayCircle("Ç.A", true, context),
              _buildDayCircle("Ç", true, context),
              _buildDayCircle("C.A", true, context),
              _buildDayCircle("C", true, context),
              _buildDayCircle("Ş", true, context),
              _buildDayCircle("B", true, context),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '09:00 - 23:00 PM',
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

  Widget _buildDayCircle(String day, bool isPartTime, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 6),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(ImageAssets.dayBackContainer)),
        shape: BoxShape.circle,
        color: AppTheme.focusColor,
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
