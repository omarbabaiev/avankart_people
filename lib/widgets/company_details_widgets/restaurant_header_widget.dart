import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';

class RestaurantHeaderWidget extends StatelessWidget {
  final String imageUrl;
  final String distance;

  const RestaurantHeaderWidget({
    Key? key,
    required this.imageUrl,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          height: 235,
          width: double.infinity,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.onBackground.withOpacity(.9),
                  Theme.of(context).colorScheme.onBackground.withOpacity(.2),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: Row(
            children: [
              Image.asset(ImageAssets.distanceIcon,
                  color: Colors.white, height: 20),
              SizedBox(width: 4),
              Text(
                distance,
                style: TextStyle(
    fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -35,
          left: 16,
          child: Container(
            height: 70,
            width: 70,
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
