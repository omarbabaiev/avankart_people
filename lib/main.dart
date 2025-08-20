import 'package:avankart_people/controllers/notifications_controller.dart';

import 'screens/empty_state/not_found_screen.dart';
import 'utils/conts_texts.dart';
import 'utils/debug_logger.dart';
import 'package:firebase_core/firebase_core.dart';

import 'routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'screens/main/main_screen.dart';
import 'utils/app_theme.dart';
import 'controllers/theme_controller.dart';
import 'controllers/language_controller.dart';
import 'translations/app_translations.dart';
import 'bindings/initial_binding.dart';
import 'assets/image_assets.dart';
import 'services/firebase_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await Firebase.initializeApp();
    DebugLogger.firebase('initialize',
        data: 'Firebase initialized successfully');

    // Firebase Messaging'i initialize et
    final firebaseService = FirebaseService();
    await firebaseService.initialize();
    DebugLogger.firebase('messaging',
        data: 'Firebase Messaging initialized successfully');
  } catch (e) {
    DebugLogger.firebase('initialize', error: e);
  }

  await GetStorage.init();

  Get.put(ThemeController(), permanent: true);
  Get.put(LanguageController(), permanent: true);
  Get.put(NotificationsController(), permanent: true);

  // // API konfigürasyon bilgilerini yazdır
  // ApiConfig.printDebugInfo();

  // // Network durumunu kontrol et
  // NetworkUtils.printNetworkDebugInfo();

  runApp(const AvankartPeople());
}

class AvankartPeople extends StatelessWidget {
  const AvankartPeople({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: ConstTexts.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Get.find<ThemeController>().theme,
      defaultTransition: Transition.cupertino,
      translations: AppTranslations(),
      locale: Get.find<LanguageController>().locale,
      fallbackLocale: const Locale('en', 'US'),
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      unknownRoute: AppRoutes.routes.first,
    );
  }
}
