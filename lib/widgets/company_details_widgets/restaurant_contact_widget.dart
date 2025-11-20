import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:avankart_people/models/phone_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:avankart_people/utils/url_utils.dart';

class CompanyContactWidget extends StatelessWidget {
  final List<PhoneModel>? phones;
  final List<String>? websites;
  final dynamic social; // WhatsApp bilgisi için

  const CompanyContactWidget({
    Key? key,
    this.phones,
    this.websites,
    this.social,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Eğer telefon numarası yoksa widget'ı gösterme
    if (phones == null || phones!.isEmpty) {
      return SizedBox.shrink();
    }

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
                "contact".tr,
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
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._buildPhoneItems(context),
            ],
          ),
        ),
        Container(
          height: 4,
          color: Theme.of(context).colorScheme.secondary,
        ),
        if (websites != null && websites!.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 26, vertical: 20),
            child: Column(
              children: websites!
                  .map(
                    (website) => GestureDetector(
                      onTap: () => _launchUrl(website),
                      child: Row(
                        children: [
                          Image.asset(
                            ImageAssets.linkSimpleIcon,
                            height: 20,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              website,
                              style: TextStyle(
                                color: Theme.of(context).unselectedWidgetColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        Container(
          height: 100,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }

  List<Widget> _buildPhoneItems(BuildContext context) {
    List<Widget> items = [];

    // Her telefon numarası için ayrı widget oluştur
    for (var phone in phones!) {
      // Prefix ve number'ı doğru şekilde birleştir
      String prefix = phone.prefix ?? '';
      String number = phone.number ?? '';
      String fullNumber = prefix + number;

      // Eğer numara boşsa veya çok kısaysa atla
      if (fullNumber.isEmpty || fullNumber.length < 7) {
        debugPrint('[PHONE CALL] Skipping invalid phone number: $fullNumber');
        continue;
      }

      items.add(
        GestureDetector(
          onTap: () => _makePhoneCall(fullNumber),
          child: _buildPhoneNumberItem(context, fullNumber),
        ),
      );
    }

    return items;
  }

  Widget _buildWhatsAppButton(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            ImageAssets.whatsappIcon,
            height: 20,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            "WhatsApp",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFF25D366), // WhatsApp yeşil rengi
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }

  Widget _buildPhoneNumberItem(BuildContext context, String phoneNumber) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            ImageAssets.phoneCallIconDark,
            height: 20,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          SizedBox(width: 8),
          Text(
            phoneNumber,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Telefon numarasını temizle - sadece rakamlar ve + işareti kalsın
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Geçerli telefon numarası kontrolü
      if (cleanNumber.isEmpty || cleanNumber.length < 7) {
        debugPrint('[PHONE CALL] Invalid phone number: $cleanNumber');
        return;
      }

      debugPrint('[PHONE CALL] Original: $phoneNumber, Clean: $cleanNumber');

      // iOS için tel scheme kullan
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

      debugPrint('[PHONE CALL] Attempting to call: $cleanNumber');

      // canLaunchUrl kontrolü
      if (await canLaunchUrl(phoneUri)) {
        debugPrint('[PHONE CALL] Can launch URL, launching...');
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
        debugPrint('[PHONE CALL] URL launched successfully');
      } else {
        debugPrint('[PHONE CALL] Cannot launch URL for: $cleanNumber');
        // Alternatif olarak telprompt scheme'ini dene (iOS'ta daha iyi çalışabilir)
        final Uri telPromptUri = Uri(scheme: 'telprompt', path: cleanNumber);
        if (await canLaunchUrl(telPromptUri)) {
          debugPrint('[PHONE CALL] Using telprompt scheme...');
          await launchUrl(telPromptUri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint(
              '[PHONE CALL] Both tel and telprompt schemes failed for: $cleanNumber');
        }
      }
    } catch (e) {
      debugPrint('[PHONE CALL] Error making phone call: $e');
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      if (phoneNumber.isEmpty) {
        debugPrint('[WHATSAPP] No WhatsApp number available');
        return;
      }

      final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final Uri androidUri = Uri.parse('whatsapp://send?phone=$cleanNumber');
      final Uri webUri = Uri.parse('https://wa.me/$cleanNumber');

      debugPrint('[WHATSAPP] Trying to open for: $cleanNumber');
      if (await canLaunchUrl(androidUri)) {
        await launchUrl(androidUri, mode: LaunchMode.externalApplication);
        debugPrint('[WHATSAPP] Opened via whatsapp://');
        return;
      }
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        debugPrint('[WHATSAPP] Opened via wa.me');
        return;
      }
      debugPrint('[WHATSAPP] Cannot launch WhatsApp for: $cleanNumber');
    } catch (e) {
      debugPrint('[WHATSAPP] Error opening WhatsApp: $e');
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      await UrlUtils.launchWeb(url);
    } catch (e) {
      debugPrint('[RESTAURANT CONTACT] Error launching URL: $e');
    }
  }
}
