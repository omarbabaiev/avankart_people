import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/membership_controller.dart';
import 'package:avankart_people/models/membership_models.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/widgets/bottom_sheets/become_member_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MembershipListScreen extends GetView<MembershipController> {
  const MembershipListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // İlk yüklemede membership data'sını çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.memberships.isEmpty && !controller.isLoading) {
        controller.fetchMemberships(refresh: true);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'membership_list'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Obx(() {
        final isLoading = controller.isLoading;
        final isEmpty = controller.memberships.isEmpty;

        return (isEmpty && !isLoading)
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Get.isDarkMode
                            ? ImageAssets.emptyMemberDark
                            : ImageAssets.emptyMemberLight,
                        height: 100,
                        width: 100,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'company_not_found'.tr,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'you_have_not_been_a_member_of_any_company'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                      SizedBox(height: 20),
                      CupertinoButton(
                        onPressed: () {
                          BecomeMemberBottomSheet.show(context);
                        },
                        child: Text(
                          'become_a_member'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      await controller.fetchMemberships(refresh: true);
                    },
                  ),
                  SliverToBoxAdapter(
                    child: Skeletonizer(
                      enableSwitchAnimation: true,
                      enabled: isLoading,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: isLoading
                            ? 5
                            : isEmpty
                                ? 1
                                : controller.memberships.length,
                        itemBuilder: (context, index) {
                          if (isLoading) {
                            return _buildMembershipTile(
                              context,
                              Membership(
                                id: '1',
                                sirketName: 'Veysəloğlu MMC',
                                profileImagePath:
                                    '/uploads/sirket/profiles/logo.png',
                                hireDate: '14.08.2024',
                                status: 'ongoing',
                              ),
                            );
                          }

                          if (isEmpty) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      Get.isDarkMode
                                          ? ImageAssets.emptyMemberDark
                                          : ImageAssets.emptyMemberLight,
                                      height: 100,
                                      width: 100,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'company_not_found'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'you_have_not_been_a_member_of_any_company'
                                          .tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .unselectedWidgetColor,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    CupertinoButton(
                                      onPressed: () {
                                        BecomeMemberBottomSheet.show(context);
                                      },
                                      child: Text(
                                        'become_a_member'.tr,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final membership = controller.memberships[index];
                          return _buildMembershipTile(context, membership);
                        },
                      ),
                    ),
                  ),
                ],
              );
      }),
    );
  }

  GestureDetector _buildMembershipTile(
      BuildContext context, Membership membership) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.membershipDetail,
          arguments: membership,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: EdgeInsets.only(top: 4),
        color: Theme.of(context).colorScheme.onPrimary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                  child: membership.fullProfileImageUrl != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: membership.fullProfileImageUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) => Icon(
                              Icons.business_center_outlined,
                              color: Theme.of(context).unselectedWidgetColor,
                              size: 28,
                            ),
                            placeholder: (context, url) => Icon(
                              Icons.business_center_outlined,
                              color: Theme.of(context).unselectedWidgetColor,
                              size: 28,
                            ),
                          ),
                        )
                      : Icon(Icons.business,
                          color: Theme.of(context).unselectedWidgetColor),
                ),
                SizedBox(height: 8),
                Text(
                  membership.sirketName.isNotEmpty
                      ? membership.sirketName
                      : "unknown".tr,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: membership.status == 'ongoing'
                        ? AppTheme.greenColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    membership.status == 'ongoing' ? 'continue'.tr : 'left'.tr,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: membership.status == 'ongoing'
                          ? AppTheme.successColor
                          : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'membership_date'.tr,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' ${membership.hireDate.isNotEmpty ? membership.hireDate : "unknown".tr}',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                ),
                membership.status != 'ongoing'
                    ? SizedBox(height: 2)
                    : SizedBox(height: 4),
                membership.status != 'ongoing'
                    ? Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'end_date'.tr,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Theme.of(context).unselectedWidgetColor,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' ${membership.endDate?.isNotEmpty ?? false ? membership.endDate : "unknown".tr}',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
