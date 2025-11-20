import 'package:avankart_people/routes/app_routes.dart';

import '../../assets/image_assets.dart';
import '../../utils/conts_texts.dart';
import '../../utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../widgets/support_widgets/support_contact_card.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'settings'.tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'support'.tr,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'support_subtitle'.tr,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SupportSocialCard(
                      icon: ImageAssets.whatsappIcon,
                      title: 'whatsapp'.tr,
                      onTap: () =>
                          _launchWhatsAppOrCopy(ConstTexts.supportWhatsapp),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SupportSocialCard(
                      icon: ImageAssets.telegram,
                      title: 'telegram'.tr,
                      onTap: () =>
                          _launchTelegramOrCopy(ConstTexts.supportTelegram),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SupportContactCard(
                icon: ImageAssets.question,
                title: 'faq'.tr,
                onTap: () => Get.toNamed(AppRoutes.faq),
              ),
              const SizedBox(height: 16),
              SupportContactCard(
                icon: ImageAssets.envelope2,
                title: 'sorgu'.tr,
                onTap: () => Get.toNamed(AppRoutes.query),
              ),
              const SizedBox(height: 16),
              SupportContactCard(
                icon: ImageAssets.phoneCall,
                title: 'hotline'.tr,
                subtitle: ConstTexts.supportPhone,
                onTap: () => _launchPhoneOrCopy(ConstTexts.supportPhone),
              ),
              const SizedBox(height: 16),
              SupportContactCard(
                icon: ImageAssets.envelope2,
                title: 'email'.tr,
                subtitle: ConstTexts.supportEmail,
                onTap: () => _launchEmailOrCopy(ConstTexts.supportEmail),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  /// WhatsApp-i launch et, uğursuz olarsa kopyala
  Future<void> _launchWhatsAppOrCopy(String url) async {
    try {
      // WhatsApp URL'inden telefon numarasını çıkar
      // https://wa.me/0553485137 formatından numarayı al
      String? phoneNumber;
      if (url.contains('wa.me/')) {
        phoneNumber = url.split('wa.me/').last.split('?').first;
      } else if (url.contains('whatsapp.com/send?phone=')) {
        phoneNumber =
            url.split('whatsapp.com/send?phone=').last.split('&').first;
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Telefon numarasını temizle
        String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

        // Önce Android için whatsapp:// dene
        final Uri androidUri = Uri.parse('whatsapp://send?phone=$cleanNumber');
        if (await canLaunchUrl(androidUri)) {
          final bool launched = await launchUrl(
            androidUri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) {
            return; // Uğurla launch edildi
          }
        }

        // Fallback olarak https://wa.me/ dene
        final Uri webUri = Uri.parse('https://wa.me/$cleanNumber');
        if (await canLaunchUrl(webUri)) {
          final bool launched = await launchUrl(
            webUri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) {
            return; // Uğurla launch edildi
          }
        }
      }

      // Launch edilə bilməzse kopyala
      _copyToClipboard(url);
    } catch (e) {
      // Xəta olduqda kopyala
      _copyToClipboard(url);
    }
  }

  /// Telegram-i launch et, uğursuz olarsa kopyala
  Future<void> _launchTelegramOrCopy(String url) async {
    try {
      // Telegram URL'inden domain/username'i çıkar
      // https://t.me/avankart formatından domain'i al
      String? domain;
      if (url.contains('t.me/')) {
        domain = url.split('t.me/').last.split('?').first.split('/').first;
      } else if (url.contains('telegram.me/')) {
        domain =
            url.split('telegram.me/').last.split('?').first.split('/').first;
      }

      if (domain != null && domain.isNotEmpty) {
        // Önce Android için tg:// dene
        final Uri androidUri = Uri.parse('tg://resolve?domain=$domain');
        if (await canLaunchUrl(androidUri)) {
          final bool launched = await launchUrl(
            androidUri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) {
            return; // Uğurla launch edildi
          }
        }

        // Fallback olarak https://t.me/ dene
        final Uri webUri = Uri.parse('https://t.me/$domain');
        if (await canLaunchUrl(webUri)) {
          final bool launched = await launchUrl(
            webUri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) {
            return; // Uğurla launch edildi
          }
        }
      }

      // Launch edilə bilməzse kopyala
      _copyToClipboard(url);
    } catch (e) {
      // Xəta olduqda kopyala
      _copyToClipboard(url);
    }
  }

  /// Web URL-i launch et, uğursuz olarsa kopyala
  Future<void> _launchWebOrCopy(String url, String copyText) async {
    try {
      // URL formatını yoxla və düzəlt
      String formattedUrl = url;
      if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }

      final Uri uri = Uri.parse(formattedUrl);
      if (await canLaunchUrl(uri)) {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          return; // Uğurla launch edildi
        }
      }
      // Launch edilə bilməzse kopyala
      _copyToClipboard(copyText);
    } catch (e) {
      // Xəta olduqda kopyala
      _copyToClipboard(copyText);
    }
  }

  /// Telefon nömrəsini launch et, uğursuz olarsa kopyala
  Future<void> _launchPhoneOrCopy(String phone) async {
    try {
      // Telefon nömrəsini təmizlə
      String cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
      if (!cleanedPhone.startsWith('+')) {
        if (cleanedPhone.startsWith('994')) {
          cleanedPhone = '+$cleanedPhone';
        } else {
          cleanedPhone = '+994$cleanedPhone';
        }
      }

      final Uri phoneUri = Uri.parse('tel:$cleanedPhone');
      if (await canLaunchUrl(phoneUri)) {
        final bool launched = await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          return; // Uğurla launch edildi
        }
      }
      // Launch edilə bilməzse kopyala
      _copyToClipboard(phone);
    } catch (e) {
      // Xəta olduqda kopyala
      _copyToClipboard(phone);
    }
  }

  /// Email-i launch et, uğursuz olarsa kopyala
  Future<void> _launchEmailOrCopy(String email) async {
    try {
      final Uri emailUri = Uri.parse('mailto:$email');
      if (await canLaunchUrl(emailUri)) {
        final bool launched = await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          return; // Uğurla launch edildi
        }
      }
      // Launch edilə bilməzse kopyala
      _copyToClipboard(email);
    } catch (e) {
      // Xəta olduqda kopyala
      _copyToClipboard(email);
    }
  }

  /// Clipboard-a kopyala və toast göstər
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ToastUtils.showCopyToast();
  }
}
