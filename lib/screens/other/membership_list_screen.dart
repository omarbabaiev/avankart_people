import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/membership_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/widgets/restaurant_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MembershipListScreen extends GetView<MembershipController> {
  const MembershipListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MembershipController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Üzvlük',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
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
                        'Şirkət tapılmadı !',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Daha əvvəl heç bir şirkətə üzv olmadınız',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                      SizedBox(height: 20),
                      CupertinoButton(
                        onPressed: () {},
                        child: Text(
                          'Üzv ol',
                          style: GoogleFonts.poppins(
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
                    onRefresh: controller.fetchMemberships,
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
                              {
                                'id': '1',
                                'name': 'Veysəloğlu MMC',
                                'imageLink':
                                    'https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png',
                                'startDate': '14.08.2024',
                                'endDate': null,
                                'isEnd': false
                              },
                            );
                          }

                          if (isEmpty) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 64),
                                child: Column(
                                  children: [
                                    Icon(Icons.business_center_outlined,
                                        size: 64, color: Colors.grey[400]),
                                    SizedBox(height: 16),
                                    Text(
                                      'Üzvlük tapılmadı',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.grey[600],
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
      BuildContext context, Map<String, dynamic> membership) {
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
                  child: membership['imageLink'].isNotEmpty
                      ? Image.network(
                          membership['imageLink'],
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image),
                        )
                      : Icon(Icons.image),
                ),
                SizedBox(height: 8),
                Text(
                  membership['name'].isNotEmpty
                      ? membership['name']
                      : "Loading...",
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: membership['isEnd']
                        ? Theme.of(context).dividerColor
                        : Color(0xff23A26D).withOpacity(.12),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    membership['isEnd'] ? 'Ayrılıb' : 'Davam edir',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: membership['isEnd']
                          ? Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(.5)
                          : Color(0xff23A26D),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text("Üzv tarixi:",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).unselectedWidgetColor,
                        )),
                    SizedBox(width: 4),
                    Text(
                      membership['startDate'],
                      style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onBackground),
                    )
                  ],
                ),
                if (membership['isEnd'] && membership['endDate'] != null) ...[
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text("Ayrılma tarixi:",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).unselectedWidgetColor,
                          )),
                      SizedBox(width: 4),
                      Text(
                        membership['endDate'],
                        style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onBackground),
                      )
                    ],
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}
