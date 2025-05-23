import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class UrlUtils {
  static Future<void> launchEmail(String email) async {
    debugPrint('Email launch requested for: $email');

    // iOS ve Android için farklı yaklaşımlar kullanın
    if (Platform.isIOS) {
      try {
        // iOS'ta doğrudan Mail uygulamasına yönlendirme
        final Uri emailUri = Uri.parse('mailto:$email');
        debugPrint('iOS email URI: $emailUri');

        // Forceyle açmayı deneyin
        if (await canLaunchUrl(emailUri)) {
          final bool result = await launchUrl(
            emailUri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
          debugPrint('iOS email launch result: $result');
        } else {
          // Alternatif yöntem
          final Uri fallbackUri = Uri(scheme: 'mailto', path: email);
          debugPrint('iOS fallback email URI: $fallbackUri');
          await launchUrl(fallbackUri);
        }
      } catch (e) {
        debugPrint('iOS email launch error: $e');
      }
    } else {
      // Android ve diğer platformlar için standart yöntem
      try {
        final Uri emailUri = Uri(scheme: 'mailto', path: email);
        debugPrint('Non-iOS email URI: $emailUri');

        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        } else {
          debugPrint('Could not launch email: $email');
        }
      } catch (e) {
        debugPrint('Error launching email: $e');
      }
    }
  }

  static Future<void> launchPhone(String phone) async {
    // Telefon numarasının temizlenmesi
    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    debugPrint('Cleaned phone number: $cleanedPhone');

    // Numara formatını düzenle
    if (!cleanedPhone.startsWith('+')) {
      if (cleanedPhone.startsWith('994')) {
        cleanedPhone = '+$cleanedPhone';
      } else {
        cleanedPhone = '+994$cleanedPhone';
      }
    }

    debugPrint('Formatted phone number: $cleanedPhone');

    // iOS ve Android için farklı yaklaşımlar
    if (Platform.isIOS) {
      try {
        // iOS için basit telli URI
        final String urlString = 'tel:$cleanedPhone';
        final Uri telUri = Uri.parse(urlString);
        debugPrint('iOS tel URI: $telUri');

        final bool canOpen = await canLaunchUrl(telUri);
        debugPrint('Can launch on iOS: $canOpen');

        if (canOpen) {
          final bool result = await launchUrl(
            telUri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
          debugPrint('iOS tel launch result: $result');
        } else {
          // Alternatif iOS yaklaşımı
          final String encPhone = Uri.encodeComponent(cleanedPhone);
          final Uri altUri = Uri.parse('telprompt:$encPhone');
          debugPrint('iOS alternative tel URI: $altUri');

          if (await canLaunchUrl(altUri)) {
            await launchUrl(altUri);
          } else {
            debugPrint('iOS cannot launch any phone URI');
          }
        }
      } catch (e) {
        debugPrint('iOS phone launch error: $e');
      }
    } else {
      // Android için standart yaklaşım
      try {
        final Uri phoneUri = Uri.parse('tel:$cleanedPhone');
        debugPrint('Android phone URI: $phoneUri');

        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          debugPrint('Android cannot launch phone URI');
        }
      } catch (e) {
        debugPrint('Android phone launch error: $e');
      }
    }
  }

  static Future<void> launchWeb(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri webUri = Uri.parse(url);
    debugPrint('Web URI: $webUri');

    try {
      if (await canLaunchUrl(webUri)) {
        final bool result = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('Web launch result: $result');
      } else {
        debugPrint('Could not launch web URL: $url');

        // Alternatif olarak, iOS Safari'yi açmayı dene
        if (Platform.isIOS) {
          final Uri safariUri = Uri.parse('https://safari-web://$url');
          if (await canLaunchUrl(safariUri)) {
            await launchUrl(safariUri);
          }
        }
      }
    } catch (e) {
      debugPrint('Web launch error: $e');
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
}
