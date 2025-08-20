import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QueryCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String date;
  final String status;
  final VoidCallback? onTap;

  QueryCard({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              id,
              style: TextStyle(
    fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
    fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
    fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .unselectedWidgetColor
                        .withOpacity(0.03),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
    fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: switch (status) {
                        "pending" => Color(0xffF9B100),
                        "solved" => AppTheme.greenColor,
                        "draft" => Theme.of(context).unselectedWidgetColor,
                        _ => Colors.transparent,
                      },
                    ),
                    SizedBox(width: 4),
                    Text(
                      switch (status) {
                        "pending" => "pending".tr,
                        "solved" => "solved".tr,
                        "draft" => "draft".tr,
                        _ => "status_not_found".tr,
                      },
                      style: TextStyle(
    fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: switch (status) {
                          "pending" => Color(0xffF9B100),
                          "solved" => AppTheme.greenColor,
                          "draft" => Theme.of(context).colorScheme.onBackground,
                          _ => Theme.of(context).colorScheme.onBackground,
                        },
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
