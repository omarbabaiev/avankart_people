import 'package:avankart_people/widgets/company_details_widgets/restaurant_action_buttons_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_address_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_category_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_contact_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_header_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_info_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_social_media_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_working_hours_widget.dart';
import 'package:avankart_people/models/company_detail_model.dart';
import 'package:avankart_people/services/companies_service.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:avankart_people/utils/debug_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompanyDetailBottomSheet extends StatelessWidget {
  const CompanyDetailBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments from global state
    Map<String, dynamic> arguments;
    try {
      arguments =
          Get.find<Map<String, dynamic>>(tag: 'company_detail_arguments');
    } catch (e) {
      print('[Company DETAIL] Error getting arguments: $e');
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Text('Arguments not found'),
        ),
      );
    }

    final companyDetailResponse =
        arguments['company_detail'] as CompanyDetailResponse?;
    final companyId = arguments['company_id'] as String?;
    final companyDetail = companyDetailResponse?.data.responseData;

    print('[Company DETAIL] Company ID: $companyId');
    print('[Company DETAIL] Company Detail: $companyDetail');
    print('[Company DETAIL] Arguments found: ${arguments.keys}');

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CompanyHeaderWidget(
                    profileImageUrl: companyDetail?.profileImageUrl ??
                        "assets/images/image.png",
                    imageUrl: companyDetail?.coverImageUrl ??
                        "assets/images/image.png",
                    distance: companyDetail?.displayDistance ?? "0.0 km",
                  ),
                  CompanyInfoWidget(
                    name: companyDetail?.muessiseName ?? "",
                    description: companyDetail?.description ??
                        "no_description_available".tr,
                    rating: "4.8", // TODO: Get rating from API
                    schedule: companyDetail?.schedule,
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
                    address:
                        companyDetail?.address ?? "address_not_available".tr,
                    latitude: companyDetail?.latitude,
                    longitude: companyDetail?.longitude,
                  ),
                  Container(
                    height: 4,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  CompanyWorkingHoursWidget(
                    schedule: companyDetail?.schedule,
                  ),
                  Container(
                    height: 4,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  CompanyCategoryWidget(
                    categories: companyDetail?.services
                            .map((service) => CategoryItem(
                                  name: service,
                                  icon: _getServiceIcon(service),
                                ))
                            .toList() ??
                        [
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
                        name: companyDetail?.activityType ?? "Company",
                        icon: _getActivityTypeIcon(companyDetail?.activityType),
                      ),
                    ],
                  ),
                  Container(
                    height: 4,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  CompanySocialMediaWidget(
                    social: companyDetail?.social,
                  ),
                  Container(
                    height: 4,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  CompanyContactWidget(
                    phones: companyDetail?.phone,
                    websites: companyDetail?.website,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'prescription':
        return Icons.medical_services_outlined;
      case 'consultation':
        return Icons.psychology_outlined;
      case 'delivery':
        return Icons.delivery_dining;
      case 'food':
        return Icons.restaurant;
      case 'drink':
        return Icons.local_drink;
      default:
        return Icons.category;
    }
  }

  IconData? _getActivityTypeIcon(String? activityType) {
    switch (activityType?.toLowerCase()) {
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'restaurant':
        return Icons.restaurant;
      case 'cafe':
        return Icons.local_cafe;
      case 'hospital':
        return Icons.local_hospital;
      case 'clinic':
        return Icons.medical_services;
      case 'shop':
        return Icons.store;
      case 'market':
        return Icons.shopping_cart;
      default:
        return Icons.business;
    }
  }
}
