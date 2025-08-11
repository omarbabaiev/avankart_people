import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'utils/app_theme.dart';
import 'controllers/theme_controller.dart';
import 'controllers/language_controller.dart';
import 'translations/app_translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

void main() async {
  // WidgetsBinding'i başlat
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Splash screen'i koru
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // GetStorage'ı başlat
  await GetStorage.init();

  // Controller'ları başlat
  final themeController = Get.put(ThemeController(), permanent: true);
  Get.put(LanguageController(), permanent: true);

  // Status bar ve navigation bar renklerini ayarla
  _updateSystemUIOverlayStyle(themeController.theme);

  // Tema değişikliğini dinle
  ever(themeController.rxTheme, (ThemeMode themeMode) {
    _updateSystemUIOverlayStyle(themeMode);
  });

  // Uygulamayı başlat
  runApp(const MyApp());
}

void _updateSystemUIOverlayStyle(ThemeMode themeMode) {
  final isDark = themeMode == ThemeMode.dark;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: !isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Blur efekti için ek ayarlar
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Splash screen'i kaldır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Avankart People',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Get.find<ThemeController>().theme,
      defaultTransition: Transition.cupertino,
      translations: AppTranslations(),
      locale: Get.find<LanguageController>().locale,
      fallbackLocale: const Locale('az', 'AZ'),

      // GetX Router Ayarları
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,

      // Rota oluşturma ve analiz etme
      unknownRoute: GetPage(
        name: '/not-found',
        page: () =>
            const Scaffold(body: Center(child: Text('Sayfa bulunamadı'))),
      ),
    );
  }
}
