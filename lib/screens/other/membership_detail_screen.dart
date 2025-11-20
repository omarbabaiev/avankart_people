import 'package:avankart_people/controllers/membership_controller.dart';
import 'package:avankart_people/models/membership_models.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MembershipDetailScreen extends GetView<MembershipController> {
  final Membership membership = Get.arguments as Membership;

  @override
  Widget build(BuildContext context) {
    // Membership details'ı yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMembershipDetails(sirketId: membership.id);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            membership.sirketName,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Obx(() {
        final membershipDetail = controller.selectedMembershipDetail;
        final isLoadingDetails = controller.isLoadingDetails;

        return Skeletonizer(
          enabled: isLoadingDetails,
          child: ListView(
            children: [
              Container(
                color: Theme.of(context).colorScheme.onPrimary,
                margin: EdgeInsets.symmetric(vertical: 4),
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("total_spending".tr,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).unselectedWidgetColor)),
                    SizedBox(height: 8),
                    Text(
                      '${AppTheme.currencySymbol + " " + (membershipDetail?.total.toString() ?? '0')}',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                    SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        text: membershipDetail?.hireDate ?? membership.hireDate,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).unselectedWidgetColor),
                        children: [
                          TextSpan(
                            text: " > ",
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).unselectedWidgetColor),
                          ),
                          membershipDetail?.endDate != null
                              ? TextSpan(
                                  text: membershipDetail!.endDate!,
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .unselectedWidgetColor),
                                )
                              : TextSpan(
                                  text: "today".tr,
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .unselectedWidgetColor),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (membershipDetail?.categories.isNotEmpty == true) ...[
                Container(
                  color: Theme.of(context).colorScheme.onPrimary,
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("categories".tr,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).colorScheme.onBackground)),
                      SizedBox(height: 16),
                      ...membershipDetail!.categories.map((category) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category['name'] ?? 'unknown'.tr,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                              ),
                              Text(
                                '${category['spending']?.toString() ?? '0'} ${AppTheme.currencySymbol}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
