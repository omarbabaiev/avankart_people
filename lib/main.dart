import 'package:avankart_people/controllers/notifications_controller.dart';
import 'package:avankart_people/controllers/security_controller.dart';

import 'screens/empty_state/not_found_screen.dart';
import 'utils/conts_texts.dart';
import 'utils/debug_logger.dart';
import 'package:firebase_core/firebase_core.dart';

import 'routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Cihaz yönlendirmesini sadece portrait (normal) modda sabitle
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
  // SecurityController'ı permanent yapma, logout sırasında yeniden oluşturulsun
  Get.put(SecurityController());

  // // API konfigürasyon bilgilerini yazdır
  // ApiConfig.debugPrintDebugInfo();

  // // Network durumunu kontrol et
  // NetworkUtils.debugPrintNetworkDebugInfo();

  runApp(const AvankartPeople());
}

class AvankartPeople extends StatefulWidget {
  const AvankartPeople({super.key});

  @override
  State<AvankartPeople> createState() => _AvankartPeopleState();
}

class _AvankartPeopleState extends State<AvankartPeople>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Uygulama kapatıldığında authentication session'ı sıfırla
      if (Get.isRegistered<SecurityController>()) {
        Get.find<SecurityController>().resetAuthentication();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
