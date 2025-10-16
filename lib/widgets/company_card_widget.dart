import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/favorites_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/services/companies_service.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/debug_logger.dart';
import 'package:avankart_people/utils/vibration_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';

class CompanyCard extends StatefulWidget {
  final String name;
  final int index;
  final String location;
  final String distance;
  final String imageUrl;
  final bool isOpen;
  final bool hasGift;
  final String type;
  final String companyId;
  final bool isFavorite;

  const CompanyCard({
    Key? key,
    required this.name,
    required this.index,
    required this.location,
    required this.distance,
    required this.imageUrl,
    required this.type,
    required this.companyId,
    this.isOpen = true,
    this.hasGift = false,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<CompanyCard> createState() => _CompanyCardState();
}

class _CompanyCardState extends State<CompanyCard> {
  bool _isLoading = false;
  late bool _isFavorite;
  final FavoritesController favoritesController =
      Get.put<FavoritesController>(FavoritesController());

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(CompanyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget yeni isFavorite değeri aldığında state'i güncelle
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() {
        _isFavorite = widget.isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : () => _navigateToCompanyDetail(),
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          transform: _isLoading
              ? (Matrix4.identity()..scale(0.98))
              : Matrix4.identity(),
          child: Container(
            margin: EdgeInsets.only(bottom: 3),
            padding: EdgeInsets.only(
                left: widget.index % 2 == 0 ? 16 : 6,
                right: widget.index % 2 == 0 ? 6 : 16,
                top: 14),
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.onPrimary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _buildCompanyImage(context, widget.imageUrl),
                    ),
                    Positioned(
                      top: 3,
                      right: 3,
                      child: IconButton.filledTonal(
                        onPressed: () async {
                          // Favori toggle - haptic feedback
                          VibrationUtil.selectionVibrate();

                          // Toggle favorite
                          final result = await favoritesController
                              .toggleFavorite(widget.companyId);

                          // Update local state
                          setState(() {
                            _isFavorite = result;
                          });
                        },
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(.09),
                              Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(.07),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 4,
                      child: Row(
                        children: [
                          Image.asset(ImageAssets.distanceIcon,
                              color: Colors.white, height: 16),
                          SizedBox(width: 4),
                          Text(
                            widget.distance,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  offset: Offset(0.5, 0.8),
                                  blurRadius: 2,
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Company Info
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            widget.location,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Theme.of(context).unselectedWidgetColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: IgnorePointer(
                              ignoring: true,
                              child: ToggleButtons(
                                onPressed: (int index) {
                                  // handle state update here
                                },
                                fillColor:
                                    Theme.of(context).colorScheme.secondary,
                                constraints: BoxConstraints(
                                  maxHeight: 32,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                children: [
                                  switch (widget.type) {
                                    'Company' => Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(Icons.abc,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                      ),
                                    'petrol' => Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(Icons.local_gas_station,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                      ),
                                    'cafe' => Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(Icons.coffee,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                      ),
                                    'hotel' => Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(Icons.hotel,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                      ),
                                    'market' => Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(Icons.store,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                      ),
                                    'gym' => Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(Icons.fitness_center,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                      ),
                                    'pharmacy' => Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(Icons.local_pharmacy,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                      ),
                                    'beauty' => Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(Icons.face,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                      ),
                                    _ => Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(Icons.business,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                      ),
                                  },
                                  if (widget.hasGift) ...[
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.card_giftcard,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                  ],
                                ],
                                isSelected: [
                                  true,
                                  if (widget.hasGift) ...[true],
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isOpen
                                  ? Color(0xFF23A26D).withOpacity(0.12)
                                  : Color(0xFF000000).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.isOpen ? 'open'.tr : 'closed'.tr,
                              style: TextStyle(
                                color: widget.isOpen
                                    ? Colors.green
                                    : Theme.of(context).splashColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyImage(BuildContext context, String imageUrl) {
    // Eğer imageUrl network URL ise CachedNetworkImage kullan

    return FadeInImage(
      image: CachedNetworkImageProvider(
        "https://merchant.avankart.com/$imageUrl",
      ),
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: AssetImage(ImageAssets.png_logo),
      imageErrorBuilder: (context, error, stackTrace) =>
          _buildImagePlaceholder(context),
    );

    // Default placeholder
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Image.asset(
        ImageAssets.png_logo,
        width: 30,
        height: 30,
        color: AppTheme.primaryColor.withOpacity(0.3),
      ),
    );
  }

  IconData _getCompanyIcon() {
    switch (widget.type) {
      case 'Company':
        return Icons.abc;
      case 'cafe':
        return Icons.local_cafe;
      case 'petrol':
        return Icons.local_gas_station;
      case 'market':
        return Icons.store;
      case 'hotel':
        return Icons.hotel;
      case 'gym':
        return Icons.fitness_center;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'beauty':
        return Icons.face;
      default:
        return Icons.business;
    }
  }

  /// Navigate to company detail
  Future<void> _navigateToCompanyDetail() async {
    if (_isLoading) return; // Prevent multiple taps

    setState(() {
      _isLoading = true;
    });

    try {
      DebugLogger.apiRequest('COMPANY_DETAIL', {
        'company_id': widget.companyId,
        'company_name': widget.name,
      });

      // Make API request
      final companiesService = CompaniesService();
      final response = await companiesService.getCompanyDetails(
        muessiseId: widget.companyId,
        lat: null, // TODO: Get user location
        lng: null, // TODO: Get user location
      );

      if (response != null) {
        DebugLogger.apiResponse('COMPANY_DETAIL', {
          'company_id': widget.companyId,
          'success': true,
        });

        // Navigate to company detail page with data
        Get.toNamed(AppRoutes.CompanyDetail, arguments: {
          'company_detail': response,
          'company_id': widget.companyId,
        });
      } else {
        throw Exception('No data received from API');
      }
    } catch (e) {
      DebugLogger.apiError('COMPANY_DETAIL', e);
      SnackbarUtils.showErrorSnackbar('failed_to_load_company_details'.tr);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
