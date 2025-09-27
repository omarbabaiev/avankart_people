import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/services/companies_service.dart';
import 'package:avankart_people/utils/debug_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';

class CompanyCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.restaurantDetail);
      },
      child: Container(
        height: 200,
        margin: EdgeInsets.only(bottom: 3),
        padding: EdgeInsets.only(
            left: index % 2 == 0 ? 16 : 6,
            right: index % 2 == 0 ? 6 : 16,
            top: 14),
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.onPrimary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _buildCompanyImage(context),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(.2),
                    ),
                    onPressed: () => _toggleFavorite(),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 24,
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
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(.5),
                          Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(.1),
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
                        distance,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              offset: Offset(0.5, 0.5),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Restaurant Info
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
                        name,
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
                        location,
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
                            fillColor: Theme.of(context).colorScheme.secondary,
                            constraints: BoxConstraints(
                              maxHeight: 32,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            children: [
                              switch (type) {
                                'restaurant' => Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Icon(Icons.restaurant_menu,
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
                              if (hasGift) ...[
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
                              if (hasGift) ...[true],
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
                          color: isOpen
                              ? Color(0xFF23A26D).withOpacity(0.12)
                              : Color(0xFF000000).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOpen ? 'open'.tr : 'closed'.tr,
                          style: TextStyle(
                            color: isOpen
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
    );
  }

  Widget _buildCompanyImage(BuildContext context) {
    // Eğer imageUrl network URL ise CachedNetworkImage kullan
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImagePlaceholder(context),
        errorWidget: (context, url, error) => _buildImagePlaceholder(context),
      );
    }

    // Eğer local asset ise Image.asset kullan
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImagePlaceholder(context),
      );
    }

    // Default placeholder
    return _buildImagePlaceholder(context);
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCompanyIcon(),
            size: 48,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getCompanyIcon() {
    switch (type) {
      case 'restaurant':
        return Icons.restaurant;
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

  /// Favorite toggle functionality
  Future<void> _toggleFavorite() async {
    try {
      DebugLogger.apiRequest('FAVORITE_TOGGLE', {
        'company_id': companyId,
        'company_name': name,
        'is_favorite': isFavorite,
      });

      final companiesService = CompaniesService();

      if (isFavorite) {
        // Remove from favorites
        await companiesService.addToFavorites(muessiseId: companyId);
        SnackbarUtils.showSuccessSnackbar(
          'company_removed_from_favorites'.tr,
        );
      } else {
        // Add to favorites
        final response =
            await companiesService.addToFavorites(muessiseId: companyId);

        if (response['status'] == 'added') {
          // API'den gelen mesajı kullan, yoksa localization'dan al
          final message =
              response['message'] ?? 'company_added_to_favorites'.tr;
          SnackbarUtils.showSuccessSnackbar(message);
        }
      }

      DebugLogger.apiResponse('FAVORITE_TOGGLE', {
        'company_id': companyId,
        'action': isFavorite ? 'removed' : 'added',
      });
    } catch (e) {
      DebugLogger.apiError('FAVORITE_TOGGLE', e);
      SnackbarUtils.showErrorSnackbar('favorite_error'.tr);
    }
  }
}
