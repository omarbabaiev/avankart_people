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
      String facebookUrl = _formatSocialUrl(social!.facebook!, 'facebook');
      icons.add(_buildSocialMediaIcon(
          context, ImageAssets.facebookIcon, facebookUrl, 'Facebook'));
    }

    if (social?.instagram != null && social!.instagram!.isNotEmpty) {
      String instagramUrl = _formatSocialUrl(social!.instagram!, 'instagram');
      icons.add(_buildSocialMediaIcon(
          context,
          ImageAssets.instagram, // Instagram özel ikonu
          instagramUrl,
          'Instagram'));
    }

    if (social?.telegram != null && social!.telegram!.isNotEmpty) {
      String telegramUrl = _formatSocialUrl(social!.telegram!, 'telegram');
      icons.add(_buildSocialMediaIcon(
          context,
          ImageAssets.telegram, // Telegram özel ikonu
          telegramUrl,
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
      if (phoneNumber.isEmpty) {
        print('[WHATSAPP SOCIAL] No WhatsApp number available');
        return;
      }

      final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final Uri androidUri = Uri.parse('whatsapp://send?phone=$cleanNumber');
      final Uri webUri = Uri.parse('https://wa.me/$cleanNumber');

      print('[WHATSAPP SOCIAL] Trying to open for: $cleanNumber');
      if (await canLaunchUrl(androidUri)) {
        await launchUrl(androidUri, mode: LaunchMode.externalApplication);
        print('[WHATSAPP SOCIAL] Opened via whatsapp://');
        return;
      }
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        print('[WHATSAPP SOCIAL] Opened via wa.me');
        return;
      }
      print('[WHATSAPP SOCIAL] Cannot launch WhatsApp for: $cleanNumber');
    } catch (e) {
      print('[WHATSAPP SOCIAL] Error opening WhatsApp: $e');
    }
  }

  /// Sosial media URL-lərini formatla (username → tam URL)
  String _formatSocialUrl(String input, String platform) {
    // Əgər artıq tam URL-dirsə, onu olduğu kimi qaytar
    if (input.startsWith('http://') || input.startsWith('https://')) {
      return input;
    }

    // @ işarəsini sil
    String username = input.replaceAll('@', '').trim();

    // Platforma görə düzgün URL yarat
    switch (platform.toLowerCase()) {
      case 'facebook':
        return 'https://www.facebook.com/$username';
      case 'instagram':
        return 'https://www.instagram.com/$username';
      case 'telegram':
        // Telegram həm username həm də t.me formatını dəstəkləyir
        if (username.startsWith('t.me/')) {
          return 'https://$username';
        }
        return 'https://t.me/$username';
      case 'linkedin':
        return 'https://www.linkedin.com/in/$username';
      case 'twitter':
      case 'x':
        return 'https://twitter.com/$username';
      default:
        return input; // Bilinməyən platformalar üçün olduğu kimi qaytar
    }
  }
}
