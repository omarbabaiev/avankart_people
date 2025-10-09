import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompanyActionButtonsWidget extends StatelessWidget {
  const CompanyActionButtonsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: ElevatedButton(
              onPressed: () {
                _showDirectionsBottomSheet(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(ImageAssets.directionIcon,
                        color: Colors.white, height: 24),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "get_directions".tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 0,
                backgroundColor: Color(0xFF5BBE2D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(ImageAssets.phoneCallIcon,
                        color: Colors.white, height: 24),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "call".tr,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(ImageAssets.whatsappIcon, height: 24),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "whatsapp".tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDirectionsBottomSheet(BuildContext context) {
    context.showPerformantBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset(
                          ImageAssets.boltIcon,
                        ),
                      ),
                      radius: 28,
                      backgroundColor: AppTheme.tableHover,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "bolt_continue".tr,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset(
                          ImageAssets.uberIcon,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "uber_continue".tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xff24A7D3),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          ImageAssets.wazeIcon,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "waze_continue".tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.tableHover,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          ImageAssets.googleMapsIcon,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "google_maps_continue".tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }
}
