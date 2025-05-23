import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantSocialMediaWidget extends StatelessWidget {
  const RestaurantSocialMediaWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 15, top: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sosial Media",
            style: GoogleFonts.poppins(
              color: Theme.of(context).hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            children: [
              _buildSocialMediaIcon(context, ImageAssets.linkedinIcon),
              _buildSocialMediaIcon(context, ImageAssets.linkSimpleIcon),
              _buildSocialMediaIcon(context, ImageAssets.facebookIcon),
              _buildSocialMediaIcon(context, ImageAssets.whatsappIcon),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSocialMediaIcon(BuildContext context, String imagePath) {
    return Container(
      height: 44,
      width: 44,
      margin: EdgeInsets.only(right: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        shape: BoxShape.circle,
      ),
      child: Image.asset(imagePath, height: 20),
    );
  }
}
