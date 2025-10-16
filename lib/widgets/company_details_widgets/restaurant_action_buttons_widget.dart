import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/models/phone_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyActionButtonsWidget extends StatelessWidget {
  final dynamic social; // WhatsApp bilgisi için
  final List<PhoneModel>? phones; // Telefon numaraları için

  const CompanyActionButtonsWidget({
    Key? key,
    this.social,
    this.phones,
  }) : super(key: key);

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
              onPressed: _hasPhoneNumber() ? () => _makePhoneCall() : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 0,
                backgroundColor:
                    _hasPhoneNumber() ? Color(0xFF5BBE2D) : Colors.grey,
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
              onPressed: () => _openWhatsApp(),
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

  bool _hasPhoneNumber() {
    return phones != null && phones!.isNotEmpty;
  }

  Future<void> _makePhoneCall() async {
    try {
      // Telefon numarası kontrolü
      if (!_hasPhoneNumber()) {
        print('[PHONE CALL] No phone number available');
        return;
      }

      // İlk telefon numarasını al
      var firstPhone = phones!.first;
      String prefix = firstPhone.prefix ?? '';
      String number = firstPhone.number ?? '';
      String fullNumber = prefix + number;

      // Telefon numarasını temizle - sadece rakamlar ve + işareti kalsın
      String cleanNumber = fullNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Geçerli telefon numarası kontrolü
      if (cleanNumber.isEmpty || cleanNumber.length < 7) {
        print('[PHONE CALL] Invalid phone number: $cleanNumber');
        return;
      }

      print('[PHONE CALL] Original: $fullNumber, Clean: $cleanNumber');

      // iOS için tel scheme kullan
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

      print('[PHONE CALL] Attempting to call: $cleanNumber');

      // canLaunchUrl kontrolü
      if (await canLaunchUrl(phoneUri)) {
        print('[PHONE CALL] Can launch URL, launching...');
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
        print('[PHONE CALL] URL launched successfully');
      } else {
        print('[PHONE CALL] Cannot launch URL for: $cleanNumber');
        // Alternatif olarak telprompt scheme'ini dene (iOS'ta daha iyi çalışabilir)
        final Uri telPromptUri = Uri(scheme: 'telprompt', path: cleanNumber);
        if (await canLaunchUrl(telPromptUri)) {
          print('[PHONE CALL] Using telprompt scheme...');
          await launchUrl(telPromptUri, mode: LaunchMode.externalApplication);
        } else {
          print(
              '[PHONE CALL] Both tel and telprompt schemes failed for: $cleanNumber');
        }
      }
    } catch (e) {
      print('[PHONE CALL] Error making phone call: $e');
    }
  }

  Future<void> _openWhatsApp() async {
    try {
      // WhatsApp numarası kontrolü
      if (social == null ||
          social.whatsapp == null ||
          social.whatsapp.isEmpty) {
        print('[WHATSAPP] No WhatsApp number available');
        return;
      }

      String phoneNumber = social.whatsapp;

      // Phone number'dan + ve boşlukları temizle
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[+\s-]'), '');

      // WhatsApp URL'si oluştur
      String whatsappUrl = 'https://wa.me/$cleanNumber';
      final Uri uri = Uri.parse(whatsappUrl);

      print('[WHATSAPP] Opening WhatsApp for: $cleanNumber');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('[WHATSAPP] WhatsApp launched successfully');
      } else {
        print('[WHATSAPP] Cannot launch WhatsApp for: $cleanNumber');
      }
    } catch (e) {
      print('[WHATSAPP] Error opening WhatsApp: $e');
    }
  }
}
