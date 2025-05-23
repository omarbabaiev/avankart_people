import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();
  final _storage = GetStorage();
  final _storageKey = 'lang';

  // Kullanılabilir diller listesi
  final List<Map<String, dynamic>> languages = [
    {'name': 'Azərbaycan', 'locale': Locale('az', 'AZ')},
    {'name': 'English', 'locale': Locale('en', 'US')},
    {'name': 'Русский', 'locale': Locale('ru', 'RU')},
    {'name': 'Türkçe', 'locale': Locale('tr', 'TR')},
  ];

  late Locale _locale;

  Locale get locale => _locale;

  set locale(Locale value) {
    _locale = value;
  }

  String get currentLanguage {
    switch (_locale.languageCode) {
      case 'az':
        return 'Azərbaycan';
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'tr':
        return 'Türkçe';
      default:
        return 'Azərbaycan';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  void _loadLanguage() {
    final String? langCode = _storage.read(_storageKey);
    final String? countryCode = _storage.read('${_storageKey}_country');

    if (langCode != null) {
      _locale = Locale(langCode, countryCode);
    } else {
      _locale = const Locale('az', 'AZ');
    }

    Get.updateLocale(_locale);
  }

  // Dil değiştirme
  void changeLanguage(Locale locale) {
    this.locale = locale;
    Get.updateLocale(locale);
    _saveLanguage();
    update();
  }

  void _saveLanguage() {
    _storage.write(_storageKey, _locale.languageCode);
    _storage.write('${_storageKey}_country', _locale.countryCode);
  }
}
