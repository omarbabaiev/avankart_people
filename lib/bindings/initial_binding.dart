import 'package:avankart_people/controllers/notifications_controller.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/language_controller.dart';
import '../controllers/profile_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(ThemeController());
    Get.put(LanguageController());
    Get.put(NotificationsController(), permanent: true);

    // ProfileController'ı permanent olmaktan çıkardık - sadece gerekli olduğunda initialize edilecek
    Get.put(LoginController(), permanent: true);
  }
}
