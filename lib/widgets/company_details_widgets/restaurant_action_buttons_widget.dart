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
  final double? latitude; // Şirket konumu
  final double? longitude; // Şirket konumu

  const CompanyActionButtonsWidget({
    Key? key,
    this.social,
    this.phones,
    this.latitude,
    this.longitude,
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
              GestureDetector(
                onTap: () => _openBolt(),
                child: Container(
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
              ),
              GestureDetector(
                onTap: () => _openUber(),
                child: Container(
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
              ),
              GestureDetector(
                onTap: () => _openWaze(),
                child: Container(
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
              ),
              GestureDetector(
                onTap: () => _openGoogleMaps(),
                child: Container(
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
        debugPrint('[PHONE CALL] No phone number available');
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
        debugPrint('[PHONE CALL] Invalid phone number: $cleanNumber');
        return;
      }

      debugPrint('[PHONE CALL] Original: $fullNumber, Clean: $cleanNumber');

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

  Future<void> _openWhatsApp() async {
    try {
      // WhatsApp numarası kontrolü
      if (social == null ||
          social.whatsapp == null ||
          social.whatsapp.isEmpty) {
        debugPrint('[WHATSAPP] No WhatsApp number available');
        return;
      }

      final String cleanNumber =
          social.whatsapp.toString().replaceAll(RegExp(r'[^0-9+]'), '');

      // Önce Android için whatsapp:// dene, sonra https://wa.me fallback
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

  // Bolt uygulamasını aç
  Future<void> _openBolt() async {
    try {
      if (latitude == null || longitude == null) {
        debugPrint('[BOLT] No coordinates available');
        return;
      }

      final String boltUrl =
          'bolt://destination?latitude=$latitude&longitude=$longitude';
      final String fallbackUrl = 'https://bolt.eu/';

      final Uri boltUri = Uri.parse(boltUrl);
      final Uri fallbackUri = Uri.parse(fallbackUrl);

      debugPrint('[BOLT] Trying to open Bolt for: $latitude, $longitude');

      // Try app deep link first
      try {
        final launched =
            await launchUrl(boltUri, mode: LaunchMode.externalApplication);
        if (launched) {
          debugPrint('[BOLT] Opened via bolt://');
          return;
        }
      } catch (e) {
        debugPrint('[BOLT] App not installed, trying fallback: $e');
      }

      // Fallback to web
      try {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        debugPrint('[BOLT] Opened via web fallback');
      } catch (e) {
        debugPrint('[BOLT] Failed to open fallback: $e');
      }
    } catch (e) {
      debugPrint('[BOLT] Error opening Bolt: $e');
    }
  }

  // Uber uygulamasını aç
  Future<void> _openUber() async {
    try {
      if (latitude == null || longitude == null) {
        debugPrint('[UBER] No coordinates available');
        return;
      }

      final String uberUrl =
          'uber://?action=setPickup&pickup=my_location&destination[latitude]=$latitude&destination[longitude]=$longitude';
      final String fallbackUrl =
          'https://m.uber.com/ul/?action=setPickup&pickup=my_location&destination[latitude]=$latitude&destination[longitude]=$longitude';

      final Uri uberUri = Uri.parse(uberUrl);
      final Uri fallbackUri = Uri.parse(fallbackUrl);

      debugPrint('[UBER] Trying to open Uber for: $latitude, $longitude');

      // Try app deep link first
      try {
        final launched =
            await launchUrl(uberUri, mode: LaunchMode.externalApplication);
        if (launched) {
          debugPrint('[UBER] Opened via uber://');
          return;
        }
      } catch (e) {
        debugPrint('[UBER] App not installed, trying fallback: $e');
      }

      // Fallback to web
      try {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        debugPrint('[UBER] Opened via web fallback');
      } catch (e) {
        debugPrint('[UBER] Failed to open fallback: $e');
      }
    } catch (e) {
      debugPrint('[UBER] Error opening Uber: $e');
    }
  }

  // Waze uygulamasını aç
  Future<void> _openWaze() async {
    try {
      if (latitude == null || longitude == null) {
        debugPrint('[WAZE] No coordinates available');
        return;
      }

      final String wazeUrl = 'waze://?ll=$latitude,$longitude&navigate=yes';
      final String fallbackUrl =
          'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes';

      final Uri wazeUri = Uri.parse(wazeUrl);
      final Uri fallbackUri = Uri.parse(fallbackUrl);

      debugPrint('[WAZE] Trying to open Waze for: $latitude, $longitude');

      // Try app deep link first
      try {
        final launched =
            await launchUrl(wazeUri, mode: LaunchMode.externalApplication);
        if (launched) {
          debugPrint('[WAZE] Opened via waze://');
          return;
        }
      } catch (e) {
        debugPrint('[WAZE] App not installed, trying fallback: $e');
      }

      // Fallback to web
      try {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        debugPrint('[WAZE] Opened via web fallback');
      } catch (e) {
        debugPrint('[WAZE] Failed to open fallback: $e');
      }
    } catch (e) {
      debugPrint('[WAZE] Error opening Waze: $e');
    }
  }

  // Google Maps uygulamasını aç
  Future<void> _openGoogleMaps() async {
    try {
      if (latitude == null || longitude == null) {
        debugPrint('[GOOGLE MAPS] No coordinates available');
        return;
      }

      final String mapsUrl = 'comgooglemaps://?q=$latitude,$longitude';
      final String fallbackUrl =
          'https://maps.google.com/maps?q=$latitude,$longitude';

      final Uri mapsUri = Uri.parse(mapsUrl);
      final Uri fallbackUri = Uri.parse(fallbackUrl);

      debugPrint(
          '[GOOGLE MAPS] Trying to open Google Maps for: $latitude, $longitude');

      // Try app deep link first
      try {
        final launched =
            await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
        if (launched) {
          debugPrint('[GOOGLE MAPS] Opened via comgooglemaps://');
          return;
        }
      } catch (e) {
        debugPrint('[GOOGLE MAPS] App not installed, trying fallback: $e');
      }

      // Fallback to web
      try {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        debugPrint('[GOOGLE MAPS] Opened via web fallback');
      } catch (e) {
        debugPrint('[GOOGLE MAPS] Failed to open fallback: $e');
      }
    } catch (e) {
      debugPrint('[GOOGLE MAPS] Error opening Google Maps: $e');
    }
  }
}
