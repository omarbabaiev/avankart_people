import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/profile_controller.dart';
import 'package:avankart_people/utils/toast_utils.dart';
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
    // Controller'ı Get.find ile al
    final profileController = Get.find<ProfileController>();

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
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
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
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              _buildProfileTile(
                context,
                'name_surname'.tr,
                user?.name != null && user?.surname != null
                    ? '${user!.name} ${user.surname}'
                    : 'undefined'.tr,
                ImageAssets.pencil,
                () => NameChangeBottomSheet.show(context),
              ),
              _buildProfileTile(
                context,
                'birth_date'.tr,
                user?.birthDate != null
                    ? '${user!.birthDate!.day.toString().padLeft(2, '0')}.${user.birthDate!.month.toString().padLeft(2, '0')}.${user.birthDate!.year}'
                    : 'undefined'.tr,
                ImageAssets.pencil,
                () => BirthDateChangeBottomSheet.show(context),
              ),
              _buildProfileTile(
                context,
                'phone_number'.tr,
                user?.phone != null
                    ? '+${user!.phoneSuffix}${user.phone}'
                    : 'undefined'.tr,
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
                user?.peopleId ?? 'undefined'.tr,
                ImageAssets.copySimple,
                () => _copyToClipboard(user?.peopleId),
              ),
              _buildProfileTile(
                context,
                'company'.tr,
                user?.sirketId?.sirketId ??
                    user?.sirketId?.id ??
                    'undefined'.tr,
                ImageAssets.copySimple,
                () => _copyToClipboard(
                    user?.sirketId?.sirketId ?? user?.sirketId?.id),
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
