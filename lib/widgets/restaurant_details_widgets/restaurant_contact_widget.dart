import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';

class RestaurantContactWidget extends StatelessWidget {
  const RestaurantContactWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Əlaqə",
                style: TextStyle(
    fontFamily: 'Poppins',
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              _buildContactItem(
                  context, ImageAssets.phoneCallIconDark, "+994 12 404 40 40"),
              _buildContactItem(
                  context, ImageAssets.phoneCallIconDark, "+994 12 404 40 40"),
            ],
          ),
        ),
        Container(
          height: 4,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          child: Row(
            children: [
              Image.asset(ImageAssets.linkSimpleIcon, height: 20),
              SizedBox(width: 6),
              Text(
                "ozsut.com.tr",
                style: TextStyle(
                  color: Theme.of(context).unselectedWidgetColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildContactItem(
      BuildContext context, String imagePath, String text) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            height: 20,
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      height: 33,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}
