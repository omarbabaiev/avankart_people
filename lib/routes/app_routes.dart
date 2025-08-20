import 'package:avankart_people/auth/forgot_password_screen.dart';
import 'package:avankart_people/screens/auth/change_password_screen.dart';
import 'package:avankart_people/screens/auth/login_screen.dart';
import 'package:avankart_people/screens/auth/new_password_screen.dart';
import 'package:avankart_people/screens/auth/otp_screen.dart';
import 'package:avankart_people/screens/auth/register_screen.dart';
import 'package:avankart_people/screens/auth/splash_screen.dart';

import 'package:avankart_people/screens/empty_state/not_found_screen.dart';
import 'package:avankart_people/screens/initial/initial_card_select_screen.dart';
import 'package:avankart_people/screens/main/main_screen.dart';
import 'package:avankart_people/screens/other/filter_search_screen.dart';
import 'package:avankart_people/screens/other/membership_detail_screen.dart';
import 'package:avankart_people/screens/other/membership_list_screen.dart';
import 'package:avankart_people/screens/other/search_company_screen.dart';
import 'package:avankart_people/screens/payment/card_select_screen.dart';
import 'package:avankart_people/screens/initial/intro_screen.dart';
import 'package:avankart_people/screens/other/benefits_screen.dart';
import 'package:avankart_people/screens/other/favorites_screen.dart';
import 'package:avankart_people/screens/other/notifications_screen.dart';
import 'package:avankart_people/screens/other/profil_screen.dart';
import 'package:avankart_people/screens/other/restoraunt_detail_screen.dart';
import 'package:avankart_people/screens/payment/qr_payment_screen.dart';
import 'package:avankart_people/screens/security/pin_code_screen.dart';
import 'package:avankart_people/screens/security/security_screen.dart';
import 'package:avankart_people/screens/security/two_factor_authentication_screen.dart';
import 'package:avankart_people/screens/main/settings_screen.dart';
import 'package:avankart_people/screens/support/faq_screen.dart';
import 'package:avankart_people/screens/support/query_detail_screen.dart';
import 'package:avankart_people/screens/support/query_screen.dart';

import '../screens/support/terms_of_use_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/support/support_screen.dart';

import '../controllers/splash_controller.dart';

// Uygulama rotalarının tanımlandığı sınıf
class AppRoutes {
  static const String notFound = '/not-found';

  // Ana rotalar
  static const String splash = '/splash';
  static const String cards = '/cards';
  static const String login = '/login';
  static const String terms = '/terms';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String main = '/main';
  static const String forgotPassword = '/forgot-password';
  static const String newPassword = '/new-password';
  static const String changePassword = '/change-password';
  static const String restaurantDetail = '/restaurant-detail';
  static const String query = '/query';
  static const String faq = '/faq';
  static const String initialCard = '/initial-card-select';
  static const String selectCard = '/select-card';
  static const String otpScreen = '/otp-screen';
  // Alt rotalar
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String support = '/support';
  static const String createQr = '/create-qr';
  static const String qrDisplay = '/qr-display';
  static const String intro = '/intro';
  static const String notification = '/notifications';
  static const String favorites = '/favorites';
  static const String benefits = '/benefits';
  static const String security = '/security';
  static const String twoFactorAuthentication = '/two-factor-authentication';
  static const String setPinCode = '/set-pin-code';
  static const String profil = '/profil';
  static const String qrPayment = '/qr-payment';
  static const String searchCompany = '/search-company';
  static const String membershipDetail = '/membership-detail';
  static const String membershipList = '/membership-list';
  static const String filterSearch = '/filter-search';
  static const String queryDetail = '/query-detail';
  // Tüm sayfaların rota eşleştirmelerini içeren liste

  static final List<GetPage> routes = [
    GetPage(
      name: notFound,
      page: () => const NotFoundScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: queryDetail,
      page: () => QueryDetailScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: filterSearch,
      page: () => FilterSearchScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: membershipList,
      page: () => const MembershipListScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: selectCard,
      page: () => const CardSelectScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: membershipDetail,
      page: () => MembershipDetailScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: qrPayment,
      page: () => const QrPaymentScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: profil,
      page: () => ProfilScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: setPinCode,
      page: () => const SetPinCodeScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: twoFactorAuthentication,
      page: () => const TwoFactorAuthenticationScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: security,
      page: () => const SecurityScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: benefits,
      page: () => const BenefitsScreen(),
      transition: Transition.native,
    ),
    GetPage(
      name: searchCompany,
      page: () => SearchCompanyScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: query,
      page: () => QueryScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: faq,
      page: () => const FAQScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: favorites,
      page: () => const FavoritesScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: notification,
      page: () => NotificationsScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: restaurantDetail,
      page: () => const RestorauntDetailScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: query,
      page: () => QueryScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: initialCard,
      page: () => const InitialCardScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: terms,
      page: () => const TermsOfUseScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: newPassword,
      page: () => const NewPasswordScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: changePassword,
      page: () => const ChangePasswordScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: otpScreen,
      page: () => const OtpScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: support,
      page: () => const SupportScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: intro,
      page: () => const IntroScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: otp,
      page: () => const OtpScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: main,
      page: () => const MainScreen(),
      transition: Transition.cupertino,
    ),
  ];
}
