import 'package:avankart_people/widgets/company_details_widgets/restaurant_action_buttons_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_address_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_category_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_contact_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_header_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_info_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_social_media_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_working_hours_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avankart_people/models/company_detail_model.dart';

class CompanyDetailScreen extends StatelessWidget {
  const CompanyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments from navigation
    final arguments = Get.arguments as Map<String, dynamic>?;
    final companyDetailResponse =
        arguments?['company_detail'] as CompanyDetailResponse?;
    final companyId = arguments?['company_id'] as String?;
    final companyDetail = companyDetailResponse?.data.responseData;

    print('[Company DETAIL] Company ID: $companyId');
    print('[Company DETAIL] Company Detail: $companyDetail');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 60,
        elevation: 0,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 80,
        leading: IconButton.filledTonal(
          style: IconButton.styleFrom(
            maximumSize: Size(44, 44),
            backgroundColor:
                Theme.of(context).colorScheme.onPrimary.withOpacity(.3),
          ),
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
        ),
        actions: [
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              padding: EdgeInsets.all(10),
              backgroundColor:
                  Theme.of(context).colorScheme.onPrimary.withOpacity(.2),
            ),
            onPressed: () {},
            icon: Icon(
              Icons.favorite_border_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompanyHeaderWidget(
              profileImageUrl:
                  companyDetail?.profileImageUrl ?? "assets/images/image.png",
              imageUrl:
                  companyDetail?.coverImageUrl ?? "assets/images/image.png",
              distance: companyDetail?.displayDistance ?? "0.0 km",
            ),
            CompanyInfoWidget(
              name: companyDetail?.muessiseName ?? "Company Name",
              description:
                  companyDetail?.description ?? "No description available",
              rating: "4.8", // TODO: Get rating from API
              schedule:
                  companyDetail?.schedule, // TODO: Calculate from schedule
            ),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            CompanyActionButtonsWidget(),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            CompanyAddressWidget(
              address: companyDetail?.address ?? "Address not available",
            ),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            CompanyWorkingHoursWidget(),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            CompanyCategoryWidget(
              categories: [
                CategoryItem(
                  name: "Yemək",
                  icon: Icons.medical_services_outlined,
                ),
                CategoryItem(
                  name: "Nahar",
                ),
                CategoryItem(
                  name: "Şirniyyat",
                  icon: Icons.cake,
                ),
                CategoryItem(
                  name: "İçki",
                  icon: Icons.local_drink,
                ),
              ],
            ),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            CompanyCategoryWidget(
              categories: [
                CategoryItem(
                  name: "Yemək",
                ),
              ],
            ),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            CompanySocialMediaWidget(),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            CompanyContactWidget(),
          ],
        ),
      ),
    );
  }
}
