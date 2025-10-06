import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileSection extends StatelessWidget {
  final UserModel? user;
  final bool isLoading;

  const ProfileSection({
    Key? key,
    required this.user,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enableSwitchAnimation: true,
      enabled: isLoading,
      child: Column(
        children: [
          _buildProfileTile(context),
          // Company tile'ını her zaman göster
          _buildCompanyTile(context),
        ],
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: 4, top: 4),
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: ListTile(
        onTap: () {
          Get.toNamed(AppRoutes.profil);
        },
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).hoverColor,
          radius: 30,
          child: Center(
            child: Text(
              _getInitial(user?.name ?? '') + _getInitial(user?.surname ?? ''),
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Theme.of(context).primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        title: Text(
          '${user?.name} ${user?.surname}' ?? 'undefined'.tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        trailing: Image.asset(
          ImageAssets.caretRight,
          width: 24,
          height: 24,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }

  Widget _buildCompanyTile(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: ListTile(
        onTap: () {
          Get.toNamed(AppRoutes.membershipList);
        },
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            ImageAssets.addressBook,
            width: 23,
            height: 23,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        title: Text(
          'membership'.tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        subtitle: Text(
          user?.sirketId?.sirketName ?? 'undefined'.tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).unselectedWidgetColor,
          ),
        ),
        trailing: Image.asset(
          ImageAssets.caretRight,
          width: 24,
          height: 24,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }
}

Widget buildTile(
    BuildContext context, String title, String icon, VoidCallback onTap) {
  return Container(
    alignment: Alignment.center,
    margin: EdgeInsets.only(bottom: 4),
    padding: EdgeInsets.symmetric(horizontal: 16),
    height: 65,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
    child: ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          icon,
          width: 23,
          height: 23,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      trailing: Image.asset(
        ImageAssets.caretRight,
        width: 24,
        height: 24,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    ),
  );
}

String _getInitial(String text) {
  if (text.isEmpty) return '';

  // Metni boşluklara göre ayır
  List<String> words = text.trim().split(' ');

  // İlk iki kelimenin baş harflerini al
  String initials = '';
  for (int i = 0; i < words.length && i < 2; i++) {
    if (words[i].isNotEmpty) {
      initials += words[i][0].toUpperCase();
    }
  }

  return initials;
}
