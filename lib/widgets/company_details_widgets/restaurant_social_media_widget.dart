import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:avankart_people/models/social_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanySocialMediaWidget extends StatelessWidget {
  final SocialModel? social;

  const CompanySocialMediaWidget({
    Key? key,
    this.social,
  }) : super(key: key);

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
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Theme.of(context).hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            children: _buildSocialMediaIcons(context),
          )
        ],
      ),
    );
  }

  List<Widget> _buildSocialMediaIcons(BuildContext context) {
    List<Widget> icons = [];

    if (social?.facebook != null && social!.facebook!.isNotEmpty) {
      icons.add(_buildSocialMediaIcon(
          context, ImageAssets.facebookIcon, social!.facebook!, 'Facebook'));
    }

    if (social?.instagram != null && social!.instagram!.isNotEmpty) {
      icons.add(_buildSocialMediaIcon(
          context,
          ImageAssets.linkSimpleIcon, // Instagram icon yoksa generic icon
          social!.instagram!,
          'Instagram'));
    }

    if (social?.telegram != null && social!.telegram!.isNotEmpty) {
      icons.add(_buildSocialMediaIcon(
          context,
          ImageAssets.linkSimpleIcon, // Telegram icon yoksa generic icon
          social!.telegram!,
          'Telegram'));
    }

    if (social?.whatsapp != null && social!.whatsapp!.isNotEmpty) {
      icons.add(_buildSocialMediaIcon(
          context, ImageAssets.whatsappIcon, social!.whatsapp!, 'WhatsApp'));
    }

    // Eğer hiç sosyal medya yoksa boş widget döndür
    if (icons.isEmpty) {
      return [
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            "Sosial media hesabları yoxdur",
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 12,
            ),
          ),
        ),
      ];
    }

    return icons;
  }

  Widget _buildSocialMediaIcon(
      BuildContext context, String imagePath, String url, String platform) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        height: 44,
        width: 44,
        margin: EdgeInsets.only(right: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        child: Image.asset(imagePath, height: 20),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
