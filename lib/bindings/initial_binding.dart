import 'package:avankart_people/controllers/notifications_controller.dart';
import 'package:avankart_people/controllers/splash_controller.dart';
import 'package:avankart_people/controllers/membership_controller.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/language_controller.dart';
import '../controllers/profile_controller.dart';
import '../services/companies_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController(), permanent: true);
    Get.put(ThemeController());
    Get.put(LanguageController());
    Get.put(SplashController());
    Get.put(NotificationsController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    Get.put(MembershipController(), permanent: true);

    // Services
    Get.put(CompaniesService(), permanent: true);

    // ProfileController'ı permanent olarak ekledik - memory'den silinmeyecek
    Get.put(LoginController(), permanent: true);
  }
}
