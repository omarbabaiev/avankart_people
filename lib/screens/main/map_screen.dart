import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/map_controller.dart';
import '../../controllers/theme_controller.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MapController mapController = Get.put(MapController());

    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(context),
        body: _buildBody(mapController),
      ),
    );
  }

  // Optimized AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 90,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      title: GestureDetector(
        onTap: () {
          Get.toNamed(AppRoutes.searchCompany,
              arguments: {'heroTag': 'map_search_company'});
        },
        child: Hero(
          tag: 'map_search_company',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          ImageAssets.searchNormal,
                          width: 24,
                          height: 24,
                          color: Theme.of(context)
                              .bottomNavigationBarTheme
                              .unselectedItemColor,
                        ),
                        SizedBox(width: 8),
                        Material(
                          color: Colors.transparent,
                          child: Text(
                            'search_placeholder'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .bottomNavigationBarTheme
                                  .unselectedItemColor
                                  ?.withOpacity(.8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.filterSearch);
                  },
                  child: Container(
                    height: 44,
                    width: 44,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      ImageAssets.funnel,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Optimized Search Bar

  // Optimized Body
  Widget _buildBody(MapController mapController) {
    return Obx(() {
      if (mapController.isLoading.value) {
        return const _LoadingWidget();
      }

      if (mapController.hasError.value) {
        return _ErrorWidget(
          errorMessage: mapController.errorMessage.value,
          onRetry: () => mapController.initializeMap(),
        );
      }

      return _MapContent(mapController: mapController);
    });
  }
}

// Optimized Loading Widget
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Platform.isIOS
              ? CupertinoActivityIndicator(
                  color: Theme.of(context).colorScheme.onBackground,
                )
              : CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
          SizedBox(height: 16),
          Text(
            'map_loading'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Optimized Error Widget
class _ErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'map_error'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          if (errorMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'try_again'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Optimized Map Content
class _MapContent extends StatelessWidget {
  final MapController mapController;

  const _MapContent({required this.mapController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ana harita - Optimized
        _buildGoogleMap(),
      ],
    );
  }

  // Optimized Google Map with error handling
  Widget _buildGoogleMap() {
    return Builder(
      builder: (context) {
        try {
          return Obx(() {
            final themeController = Get.find<ThemeController>();
            // ThemeController'dan tema değişikliğini dinle
            themeController.rxTheme.value;
          return GetBuilder<MapController>(builder: (controller) {
            // Controller'ın dispose olup olmadığını kontrol et
            if (controller.isDisposed) {
                return _buildMapErrorWidget(
                    context, 'Map controller disposed');
            }

              // Tema algılama - ThemeController'dan tema al
              final isDark = themeController.theme == ThemeMode.dark ||
                  (themeController.theme == ThemeMode.system &&
                      Theme.of(context).brightness == Brightness.dark);
              final currentMapStyle = isDark ? _darkMapStyle : _lightMapStyle;

              // Tema değiştiğinde map style'ı güncelle
              if (controller.mapController != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.mapController?.setMapStyle(currentMapStyle);
                });
              }

              return GoogleMap(
                onMapCreated: (GoogleMapController googleMapController) {
                  controller.onMapCreated(googleMapController);
                  // Map style'ı uygula
                  googleMapController.setMapStyle(currentMapStyle);
                },
                  onCameraMove: controller.onCameraMove,
                  onCameraIdle: controller.onCameraIdle,
                  initialCameraPosition: CameraPosition(
                    target: controller.currentPosition.value != null
                        ? LatLng(
                            controller.currentPosition.value!.latitude,
                            controller.currentPosition.value!.longitude,
                          )
                        : controller.defaultLocation,
                    zoom: 15.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: Set<Marker>.from(controller.markers),
                circles: _buildCircles(context, controller),
                onTap: (position) => _onMapTap(position, controller),
                  // Performance optimizations
                  liteModeEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  indoorViewEnabled: false,
                  trafficEnabled: false,
                  buildingsEnabled: false,
              );
            });
          });
        } catch (e) {
          debugPrint('GoogleMap widget hatası: $e');
          return _buildMapErrorWidget(context, e.toString());
        }
      },
    );
  }

  // Optimized Circles
  Set<Circle> _buildCircles(BuildContext context, MapController mapController) {
    if (mapController.currentPosition.value != null) {
      final primaryColor = Theme.of(context).colorScheme.primary;
      return {
        Circle(
          circleId: const CircleId('search_radius'),
          center: LatLng(
            mapController.currentPosition.value!.latitude,
            mapController.currentPosition.value!.longitude,
          ),
          radius: 500, // 500 metre yarıçap
          fillColor: primaryColor.withOpacity(0.2),
          strokeColor: primaryColor.withOpacity(0.5),
          strokeWidth: 2,
        ),
      };
    }
    return {};
  }

  // Optimized Map Tap
  void _onMapTap(LatLng position, MapController mapController) {
    mapController.addMarker(
      position,
      'Seçilen Konum',
      '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
    );
  }

  // Optimized Map Error Widget
  Widget _buildMapErrorWidget(BuildContext context, String error) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 64,
              color: Theme.of(context).unselectedWidgetColor,
            ),
            const SizedBox(height: 16),
            Text(
              'map_error'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Google Maps Dark Theme Style - App Theme Uyumlu
// Primary Color Palette: #745086, #88649A, #9C78AE
// Background: #0F171B, #111418, #1D2024
const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{ "color": "#0F171B" }]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#BFC8CC" }]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{ "color": "#0F171B" }, { "weight": 0.5 }]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{ "color": "#1D2024" }]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#745086" }, { "weight": 1 }]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#88649A" }, { "weight": 0.5 }]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#8B8B8B" }]
  },
  {
    "featureType": "administrative.neighborhood",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#BFC8CC" }]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{ "color": "#1D2024" }]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#BFC8CC" }]
  },
  {
    "featureType": "poi.attraction",
    "elementType": "geometry",
    "stylers": [{ "color": "#2A1D2D" }]
  },
  {
    "featureType": "poi.attraction",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#9C78AE" }]
  },
  {
    "featureType": "poi.business",
    "elementType": "geometry",
    "stylers": [{ "color": "#251F2A" }]
  },
  {
    "featureType": "poi.business",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#88649A" }]
  },
  {
    "featureType": "poi.medical",
    "elementType": "geometry",
    "stylers": [{ "color": "#2A1D2D" }]
  },
  {
    "featureType": "poi.medical",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#9C78AE" }]
  },
  {
    "featureType": "poi.place_of_worship",
    "elementType": "geometry",
    "stylers": [{ "color": "#251F2A" }]
  },
  {
    "featureType": "poi.place_of_worship",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#88649A" }]
  },
  {
    "featureType": "poi.school",
    "elementType": "geometry",
    "stylers": [{ "color": "#251F2A" }]
  },
  {
    "featureType": "poi.school",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#88649A" }]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "geometry",
    "stylers": [{ "color": "#251F2A" }]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#88649A" }]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{ "color": "#1A2A1A" }]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#8B8B8B" }]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{ "color": "#1D2024" }]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{ "color": "#252930" }]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#88649A" }, { "weight": 0.3 }]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#BFC8CC" }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{ "color": "#745086" }, { "weight": 1.5 }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#88649A" }, { "weight": 0.8 }]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#E1E2E8" }]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [{ "color": "#745086" }, { "weight": 2 }]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#9C78AE" }, { "weight": 1 }]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry",
    "stylers": [{ "color": "#1D2024" }]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#2A1D2D" }, { "weight": 0.2 }]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#BFC8CC" }]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [{ "color": "#1D2024" }]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [{ "color": "#745086" }, { "weight": 1.5 }]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#88649A" }, { "weight": 0.5 }]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [{ "color": "#745086" }]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#88649A" }, { "weight": 1 }]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#E1E2E8" }]
  },
  {
    "featureType": "transit.station.airport",
    "elementType": "geometry",
    "stylers": [{ "color": "#88649A" }]
  },
  {
    "featureType": "transit.station.airport",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#E1E2E8" }]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "geometry",
    "stylers": [{ "color": "#9C78AE" }]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#E1E2E8" }]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{ "color": "#0A1216" }]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#8B8B8B" }]
  }
]
''';

// Google Maps Light Theme Style - App Theme Uyumlu
// Primary Color Palette: #745086, #88649A, #9C78AE
// Background: #FAFAFA, #F8F9FF, #FFFFFF
const String _lightMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{ "color": "#FAFAFA" }]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#1D222B" }]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{ "color": "#FFFFFF" }, { "weight": 1 }]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{ "color": "#F8F9FF" }]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#745086" }, { "weight": 1 }]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#88649A" }, { "weight": 0.5 }]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#70787C" }]
  },
  {
    "featureType": "administrative.neighborhood",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#40484C" }]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{ "color": "#F8F9FF" }]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#40484C" }]
  },
  {
    "featureType": "poi.attraction",
    "elementType": "geometry",
    "stylers": [{ "color": "#F5F2F7" }]
  },
  {
    "featureType": "poi.attraction",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#745086" }]
  },
  {
    "featureType": "poi.business",
    "elementType": "geometry",
    "stylers": [{ "color": "#F2F0F5" }]
  },
  {
    "featureType": "poi.business",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#88649A" }]
  },
  {
    "featureType": "poi.medical",
    "elementType": "geometry",
    "stylers": [{ "color": "#F5F2F7" }]
  },
  {
    "featureType": "poi.medical",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#745086" }]
  },
  {
    "featureType": "poi.place_of_worship",
    "elementType": "geometry",
    "stylers": [{ "color": "#F2F0F5" }]
  },
  {
    "featureType": "poi.place_of_worship",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#88649A" }]
  },
  {
    "featureType": "poi.school",
    "elementType": "geometry",
    "stylers": [{ "color": "#F2F0F5" }]
  },
  {
    "featureType": "poi.school",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#88649A" }]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "geometry",
    "stylers": [{ "color": "#F2F0F5" }]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#88649A" }]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{ "color": "#E8F5E9" }]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#70787C" }]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{ "color": "#FFFFFF" }]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{ "color": "#F8F9FF" }]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#88649A" }, { "weight": 0.3 }]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#40484C" }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{ "color": "#745086" }, { "weight": 1.5 }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#88649A" }, { "weight": 0.8 }]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#1D222B" }]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [{ "color": "#745086" }, { "weight": 2 }]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#9C78AE" }, { "weight": 1 }]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry",
    "stylers": [{ "color": "#FFFFFF" }]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#F5F2F7" }, { "weight": 0.2 }]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#70787C" }]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [{ "color": "#F8F9FF" }]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [{ "color": "#745086" }, { "weight": 1.5 }]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#88649A" }, { "weight": 0.5 }]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [{ "color": "#745086" }]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#88649A" }, { "weight": 1 }]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#FFFFFF" }]
  },
  {
    "featureType": "transit.station.airport",
    "elementType": "geometry",
    "stylers": [{ "color": "#88649A" }]
  },
  {
    "featureType": "transit.station.airport",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#FFFFFF" }]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "geometry",
    "stylers": [{ "color": "#9C78AE" }]
  },
  {
    "featureType": "transit.station.bus",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#FFFFFF" }]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{ "color": "#DBE4E8" }]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#70787C" }]
  }
]
''';

// Optimized Location Button
// Removed Location button as requested

// Optimized Zoom Controls
// Removed Zoom controls as requested
