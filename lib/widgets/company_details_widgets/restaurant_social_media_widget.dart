import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:avankart_people/models/social_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:avankart_people/utils/url_utils.dart';

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
          ImageAssets.instagram, // Instagram özel ikonu
          social!.instagram!,
          'Instagram'));
    }

    if (social?.telegram != null && social!.telegram!.isNotEmpty) {
      icons.add(_buildSocialMediaIcon(
          context,
          ImageAssets.telegram, // Telegram özel ikonu
          social!.telegram!,
          'Telegram'));
    }

    if (social?.whatsapp != null && social!.whatsapp!.isNotEmpty) {
      icons.add(_buildSocialMediaIcon(
          context, ImageAssets.whatsappIcon, social!.whatsapp!, 'WhatsApp',
          isWhatsApp: true));
    }

    // LinkedIn için gelecekteki destek (şu an social model'de yok)
    // if (social?.linkedin != null && social!.linkedin!.isNotEmpty) {
    //   icons.add(_buildSocialMediaIcon(
    //       context, ImageAssets.linkedinIcon, social!.linkedin!, 'LinkedIn'));
    // }

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
      BuildContext context, String imagePath, String url, String platform,
      {bool isWhatsApp = false}) {
    return GestureDetector(
      onTap: () => isWhatsApp ? _openWhatsApp(url) : _launchUrl(url),
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
    try {
      await UrlUtils.launchWeb(url);
    } catch (e) {
      print('[RESTAURANT SOCIAL MEDIA] Error launching URL: $e');
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // WhatsApp numarası kontrolü
      if (phoneNumber.isEmpty) {
        print('[WHATSAPP SOCIAL] No WhatsApp number available');
        return;
      }

      // Phone number'dan + ve boşlukları temizle
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[+\s-]'), '');

      // WhatsApp URL'si oluştur
      String whatsappUrl = 'https://wa.me/$cleanNumber';
      final Uri uri = Uri.parse(whatsappUrl);

      print('[WHATSAPP SOCIAL] Opening WhatsApp for: $cleanNumber');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('[WHATSAPP SOCIAL] WhatsApp launched successfully');
      } else {
        print('[WHATSAPP SOCIAL] Cannot launch WhatsApp for: $cleanNumber');
      }
    } catch (e) {
      print('[WHATSAPP SOCIAL] Error opening WhatsApp: $e');
    }
  }
}
