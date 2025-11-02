import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_action_buttons_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_address_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_category_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_contact_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_header_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_info_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_social_media_widget.dart';
import 'package:avankart_people/widgets/company_details_widgets/restaurant_working_hours_widget.dart';
import 'package:avankart_people/models/company_detail_model.dart';
import 'package:avankart_people/controllers/favorites_controller.dart';
import 'package:avankart_people/utils/vibration_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompanyDetailScreen extends StatefulWidget {
  const CompanyDetailScreen({super.key});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  bool? _isFavorite;
  bool _isLoading = false;
  final FavoritesController favoritesController =
      Get.put<FavoritesController>(FavoritesController());

  @override
  Widget build(BuildContext context) {
    // Get arguments from navigation
    final arguments = Get.arguments as Map<String, dynamic>?;
    final companyDetailResponse =
        arguments?['company_detail'] as CompanyDetailResponse?;
    final companyId = arguments?['company_id'] as String?;
    final companyDetail = companyDetailResponse?.data.responseData;

    print('[Company DETAIL] Company ID: $companyId');
    print('[Company DETAIL] Company Detail: ${companyDetail?.toJson()}');
    print(
        '[Company DETAIL] Company Detail isFavorite: ${companyDetail?.isFavorite}');

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
              maximumSize: Size(44, 44),
              backgroundColor:
                  Theme.of(context).colorScheme.onPrimary.withOpacity(.3),
            ),
            onPressed: _isLoading ? null : _toggleFavorite,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    companyDetail?.isFavorite == true
                        ? Icons.favorite
                        : Icons.favorite_border,
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
                  companyDetail?.profileImageUrl ?? ImageAssets.png_logo,
              imageUrl: companyDetail?.coverImageUrl ?? ImageAssets.png_logo,
              distance: companyDetail?.displayDistance ?? "0.0 km",
            ),
            CompanyInfoWidget(
              name: companyDetail?.muessiseName ?? "",
              description:
                  companyDetail?.description ?? "no_description_available".tr,
              schedule: companyDetail?.schedule,
            ),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            CompanyActionButtonsWidget(
              social: companyDetail?.social,
              phones: companyDetail?.phone,
              latitude: companyDetail?.latitude,
              longitude: companyDetail?.longitude,
            ),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            CompanyAddressWidget(
              address: companyDetail?.address ?? "address_not_available".tr,
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
                      name: "unknown".tr,
                      icon: Icons.category,
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
            // Social Media sadece varsa göster
            if (_hasSocialMedia(companyDetail?.social)) ...[
              Container(
                height: 4,
                color: Theme.of(context).colorScheme.secondary,
              ),
              CompanySocialMediaWidget(
                social: companyDetail?.social,
              ),
            ],
            // Contact sadece varsa göster
            if (_hasContactInfo(
                companyDetail?.phone, companyDetail?.website)) ...[
              Container(
                height: 4,
                color: Theme.of(context).colorScheme.secondary,
              ),
              CompanyContactWidget(
                phones: companyDetail?.phone,
                websites: companyDetail?.website,
                social: companyDetail?.social,
              ),
            ],
          ],
        ),
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

  /// Check if social media info exists
  bool _hasSocialMedia(social) {
    if (social == null) return false;
    return (social.facebook != null && social.facebook!.isNotEmpty) ||
        (social.instagram != null && social.instagram!.isNotEmpty) ||
        (social.telegram != null && social.telegram!.isNotEmpty) ||
        (social.whatsapp != null && social.whatsapp!.isNotEmpty);
  }

  /// Check if contact info exists - sadece telefon numarası kontrol et
  bool _hasContactInfo(phones, websites) {
    return phones != null && phones.isNotEmpty;
  }

  /// Toggle favorite status
  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    // Favori toggle - haptic feedback
    VibrationUtil.selectionVibrate();

    setState(() {
      _isLoading = true;
    });

    try {
      // Get company ID from arguments
      final arguments = Get.arguments as Map<String, dynamic>?;
      final companyId = arguments?['company_id'] as String?;

      if (companyId == null) {
        throw Exception('Company ID not found');
      }

      // Toggle favorite using controller
      final result = await favoritesController.toggleFavorite(companyId);

      // Update local state
      setState(() {
        _isFavorite = result;
      });
    } catch (e) {
      print('[CompanyDetailScreen] Error toggling favorite: $e');
      // Error handling is already done in the controller
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
