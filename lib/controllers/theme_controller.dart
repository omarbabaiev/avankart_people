import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'themeMode';

  final _theme = ThemeMode.system.obs;
  ThemeMode get theme => _theme.value;
  Rx<ThemeMode> get rxTheme => _theme;

  // Tema adı
  String get themeName {
    return _theme.value == ThemeMode.light
        ? 'light_mode'.tr
        : _theme.value == ThemeMode.dark
            ? 'dark_mode'.tr
            : 'system_mode'.tr;
  }

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromBox();
  }

  // Tema değişikliği için tek bir method
  void changeTheme(ThemeMode mode) {
    _theme.value = mode;
    Get.changeThemeMode(_theme.value);
    _saveTheme();
  }

  // Kutudan temayı yükle
  void _loadThemeFromBox() {
    final value = _box.read(_key);
    if (value != null) {
      final index = value as int;
      _theme.value = ThemeMode.values[index];
    } else {
      _theme.value = ThemeMode.system;
    }
    Get.changeThemeMode(_theme.value);
  }

  void _saveTheme() {
    _box.write(_key, _theme.value.index);
  }
}
