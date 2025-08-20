import 'package:avankart_people/utils/debug_logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:avankart_people/utils/debug_logger.dart';
import 'dart:io' show Platform;

class UrlUtils {
  static Future<void> launchEmail(String email) async {
    DebugLogger.urlLaunch(email, 'email');

    // iOS ve Android için farklı yaklaşımlar kullanın
    if (Platform.isIOS) {
      try {
        // iOS'ta doğrudan Mail uygulamasına yönlendirme
        final Uri emailUri = Uri.parse('mailto:$email');
        DebugLogger.debug(LogCategory.url, 'iOS email URI: $emailUri');

        // Forceyle açmayı deneyin
        if (await canLaunchUrl(emailUri)) {
          final bool result = await launchUrl(
            emailUri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
          DebugLogger.debug(
              LogCategory.url, 'iOS email launch result: $result');
        } else {
          // Alternatif yöntem
          final Uri fallbackUri = Uri(scheme: 'mailto', path: email);
          DebugLogger.debug(
              LogCategory.url, 'iOS fallback email URI: $fallbackUri');
          await launchUrl(fallbackUri);
        }
      } catch (e) {
        DebugLogger.urlLaunch(email, 'email', error: e);
      }
    } else {
      // Android ve diğer platformlar için standart yöntem
      try {
        final Uri emailUri = Uri(scheme: 'mailto', path: email);
        DebugLogger.debug(LogCategory.url, 'Non-iOS email URI: $emailUri');

        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        } else {
          DebugLogger.warning(
              LogCategory.url, 'Could not launch email: $email');
        }
      } catch (e) {
        DebugLogger.urlLaunch(email, 'email', error: e);
      }
    }
  }

  static Future<void> launchPhone(String phone) async {
    // Telefon numarasının temizlenmesi
    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    DebugLogger.debug(LogCategory.url, 'Cleaned phone number: $cleanedPhone');

    // Numara formatını düzenle
    if (!cleanedPhone.startsWith('+')) {
      if (cleanedPhone.startsWith('994')) {
        cleanedPhone = '+$cleanedPhone';
      } else {
        cleanedPhone = '+994$cleanedPhone';
      }
    }

    DebugLogger.debug(LogCategory.url, 'Formatted phone number: $cleanedPhone');

    // iOS ve Android için farklı yaklaşımlar
    if (Platform.isIOS) {
      try {
        // iOS için basit telli URI
        final String urlString = 'tel:$cleanedPhone';
        final Uri telUri = Uri.parse(urlString);
        DebugLogger.debug(LogCategory.url, 'iOS tel URI: $telUri');

        final bool canOpen = await canLaunchUrl(telUri);
        DebugLogger.debug(LogCategory.url, 'Can launch on iOS: $canOpen');

        if (canOpen) {
          final bool result = await launchUrl(
            telUri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
          DebugLogger.debug(LogCategory.url, 'iOS tel launch result: $result');
        } else {
          // Alternatif iOS yaklaşımı
          final String encPhone = Uri.encodeComponent(cleanedPhone);
          final Uri altUri = Uri.parse('telprompt:$encPhone');
          DebugLogger.debug(
              LogCategory.url, 'iOS alternative tel URI: $altUri');

          if (await canLaunchUrl(altUri)) {
            await launchUrl(altUri);
          } else {
            DebugLogger.warning(
                LogCategory.url, 'iOS cannot launch any phone URI');
          }
        }
      } catch (e) {
        DebugLogger.urlLaunch(cleanedPhone, 'phone', error: e);
      }
    } else {
      // Android için standart yaklaşım
      try {
        final Uri phoneUri = Uri.parse('tel:$cleanedPhone');
        DebugLogger.debug(LogCategory.url, 'Android phone URI: $phoneUri');

        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          DebugLogger.warning(
              LogCategory.url, 'Android cannot launch phone URI');
        }
      } catch (e) {
        DebugLogger.urlLaunch(cleanedPhone, 'phone', error: e);
      }
    }
  }

  static Future<void> launchWeb(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri webUri = Uri.parse(url);
    DebugLogger.debug(LogCategory.url, 'Web URI: $webUri');

    try {
      if (await canLaunchUrl(webUri)) {
        final bool result = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        DebugLogger.debug(LogCategory.url, 'Web launch result: $result');
      } else {
        DebugLogger.warning(LogCategory.url, 'Could not launch web URL: $url');

        // Alternatif olarak, iOS Safari'yi açmayı dene
        if (Platform.isIOS) {
          final Uri safariUri = Uri.parse('https://safari-web://$url');
          if (await canLaunchUrl(safariUri)) {
            await launchUrl(safariUri);
          }
        }
      }
    } catch (e) {
      DebugLogger.urlLaunch(url, 'web', error: e);
    }
  }

  static Future<void> launchMap(double latitude, double longitude) async {
    debugPrint('Map launch requested for: $latitude,$longitude');

    if (Platform.isIOS) {
      try {
        // iOS için Apple Maps
        final String appleMapsUrl =
            'https://maps.apple.com/?q=$latitude,$longitude';
        final Uri appleMapsUri = Uri.parse(appleMapsUrl);
        debugPrint('iOS Apple Maps URL: $appleMapsUrl');

        if (await canLaunchUrl(appleMapsUri)) {
          final bool result = await launchUrl(
            appleMapsUri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
          debugPrint('iOS Apple Maps launch result: $result');
          if (result) return;
        }

        // Alternatif olarak maps:// şemasını dene
        final Uri altMapsUri = Uri.parse('maps://?q=$latitude,$longitude');
        debugPrint('iOS alternative Maps URL: $altMapsUri');

        if (await canLaunchUrl(altMapsUri)) {
          await launchUrl(altMapsUri);
          return;
        }

        // Son çare olarak Google Maps web sayfasını dene
        final Uri webMapsUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
        );
        debugPrint('iOS web Maps URL: $webMapsUri');

        if (await canLaunchUrl(webMapsUri)) {
          await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint('iOS cannot launch any maps URL');
        }
      } catch (e) {
        debugPrint('iOS maps launch error: $e');
      }
    } else {
      // Android için Google Maps
      try {
        final String googleMapsUrl =
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
        final Uri googleMapsUri = Uri.parse(googleMapsUrl);
        debugPrint('Android Google Maps URL: $googleMapsUrl');

        if (await canLaunchUrl(googleMapsUri)) {
          await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        } else {
          // Alternatif geo: URI'yi dene
          final Uri geoUri = Uri.parse('geo:$latitude,$longitude');
          debugPrint('Android alternative Geo URL: $geoUri');

          if (await canLaunchUrl(geoUri)) {
            await launchUrl(geoUri);
          } else {
            debugPrint('Android cannot launch any maps URL');
          }
        }
      } catch (e) {
        debugPrint('Android maps launch error: $e');
      }
    }
  }

  /// Platforma uygun store'a yönlendirme (App Store veya Google Play Store)
  static Future<void> launchStore() async {
    debugPrint('Store launch requested');

    if (Platform.isIOS) {
      try {
        // iOS için App Store - APP_ID'yi gerçek App Store ID'niz ile değiştirin
        const String appStoreId =
            'YOUR_APP_STORE_ID'; // Bu değeri gerçek App Store ID'niz ile değiştirin
        final String appStoreUrl = 'https://apps.apple.com/app/id$appStoreId';
        final Uri appStoreUri = Uri.parse(appStoreUrl);
        debugPrint('iOS App Store URL: $appStoreUrl');

        if (await canLaunchUrl(appStoreUri)) {
          final bool result = await launchUrl(
            appStoreUri,
            mode: LaunchMode.externalApplication,
          );
          debugPrint('iOS App Store launch result: $result');
        } else {
          debugPrint('iOS cannot launch App Store URL');
        }
      } catch (e) {
        debugPrint('iOS store launch error: $e');
      }
    } else {
      // Android için Google Play Store
      try {
        // Android package name - AndroidManifest.xml'deki package ile aynı
        const String packageName = 'com.avankart.partner';
        final String playStoreUrl =
            'https://play.google.com/store/apps/details?id=$packageName';
        final Uri playStoreUri = Uri.parse(playStoreUrl);
        debugPrint('Android Play Store URL: $playStoreUrl');

        if (await canLaunchUrl(playStoreUri)) {
          final bool result = await launchUrl(
            playStoreUri,
            mode: LaunchMode.externalApplication,
          );
          debugPrint('Android Play Store launch result: $result');
        } else {
          debugPrint('Android cannot launch Play Store URL');
        }
      } catch (e) {
        debugPrint('Android store launch error: $e');
      }
    }
  }
}
