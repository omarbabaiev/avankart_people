import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/profile_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/screens/security/pin_code_screen.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/utils/masked_text_formatter.dart';
import 'package:avankart_people/utils/toast_utils.dart';
import 'package:avankart_people/widgets/restaurant_card_widget.dart';
import 'package:avankart_people/widgets/bottom_sheets/name_change_bottom_sheet.dart';
import 'package:avankart_people/widgets/bottom_sheets/birth_date_change_bottom_sheet.dart';
import 'package:avankart_people/widgets/bottom_sheets/phone_change_bottom_sheet.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfilScreen extends StatelessWidget {
  ProfilScreen({Key? key}) : super(key: key) {
    // Controller'ı initialize et
    final profileController = Get.put(ProfileController());

    // Sadece ilk kez açıldığında profil verilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Eğer profile data yoksa yükle
      if (profileController.profile.value == null) {
        profileController.getProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: false,
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Profil',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Obx(() {
        final user = profileController.profile.value;
        final isLoading = profileController.isLoading.value;

        return Skeletonizer(
          enabled: isLoading,
          enableSwitchAnimation: true,
          child: ListView(
            children: [
              Container(
                height: 4,
                color: Theme.of(context).colorScheme.secondary,
              ),
              _buildProfileTile(
                context,
                'name_surname'.tr,
                user?.fullName ?? 'undefined'.tr,
                ImageAssets.pencil,
                () => NameChangeBottomSheet.show(context),
              ),
              _buildProfileTile(
                context,
                'birth_date'.tr,
                user?.formattedBirthDate ?? 'undefined'.tr,
                ImageAssets.pencil,
                () => BirthDateChangeBottomSheet.show(context),
              ),
              _buildProfileTile(
                context,
                'phone_number'.tr,
                user?.formattedPhone ?? 'undefined'.tr,
                ImageAssets.pencil,
                () => _showPhoneChange(context),
              ),
              _buildProfileTile(
                context,
                'gender'.tr,
                'Kişi', // API'den gelmiyorsa default değer
                ImageAssets.pencil,
                () {},
              ),
              _buildProfileTile(
                context,
                'user_id'.tr,
                user?.partnyorId ?? 'undefined'.tr,
                ImageAssets.copySimple,
                () => _copyToClipboard(user?.partnyorId),
              ),
              _buildProfileTile(
                context,
                'company'.tr,
                user?.muessiseName ?? 'undefined'.tr,
                ImageAssets.copySimple,
                () => _copyToClipboard(user?.muessiseName),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _copyToClipboard(String? text) {
    if (text != null && text.isNotEmpty && text != 'undefined'.tr) {
      Clipboard.setData(ClipboardData(text: text));
      ToastUtils.showCopyToast();
    }
  }

  void _showPhoneChange(BuildContext context) {
    Country selectedCountry = Country(
      phoneCode: "994",
      countryCode: "AZ",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "Azerbaijan",
      example: "501234567",
      displayName: "Azerbaijan (AZ) [+994]",
      displayNameNoCountryCode: "Azerbaijan (AZ)",
      e164Key: "",
    );

    PhoneChangeBottomSheet.show(context, selectedCountry, (country) {
      selectedCountry = country;
    });
  }

  ListTile _buildProfileTile(
    BuildContext context,
    String title,
    String subtitle,
    String icon,
    void Function() onTap,
  ) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Theme.of(context).unselectedWidgetColor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          icon,
          color: Theme.of(context).colorScheme.onBackground,
          height: 24,
          width: 24,
        ),
      ),
    );
  }
}
