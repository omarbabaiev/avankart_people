import 'package:avankart_people/assets/image_assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CompanyHeaderWidget extends StatelessWidget {
  final String imageUrl;
  final String distance;
  final String profileImageUrl;

  const CompanyHeaderWidget({
    Key? key,
    required this.imageUrl,
    required this.distance,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(.1),
          child: FadeInImage(
            placeholder: AssetImage(ImageAssets.notFound),
            image: CachedNetworkImageProvider(
              "https://merchant.avankart.com/$imageUrl",
            ),
            imageErrorBuilder: (context, error, stackTrace) =>
                Image.asset(ImageAssets.notFound),
            fit: BoxFit.cover,
          ),
          height: 250,
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
                  Theme.of(context).colorScheme.onBackground.withOpacity(.09),
                  Theme.of(context).colorScheme.onBackground.withOpacity(.07),
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
            child: FadeInImage(
              placeholder: AssetImage(ImageAssets.notFound),
              image: CachedNetworkImageProvider(
                "https://merchant.avankart.com/$profileImageUrl",
              ),
              imageErrorBuilder: (context, error, stackTrace) =>
                  Image.asset(ImageAssets.notFound),
              fit: BoxFit.cover,
            ),
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
