import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/map_controller.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MapController mapController = Get.put(MapController());

    return SafeArea(
      bottom: false,
      child: Scaffold(
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
              ? CupertinoActivityIndicator()
              : CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('map_loading'.tr),
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
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'map_error'.tr,
            style: TextStyle(fontSize: 16),
          ),
          if (errorMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('try_again'.tr),
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
          return GetBuilder<MapController>(builder: (controller) {
            // Controller'ın dispose olup olmadığını kontrol et
            if (controller.isDisposed) {
              return _buildMapErrorWidget('Map controller disposed');
            }

            return Obx(() => GoogleMap(
                  onMapCreated: controller.onMapCreated,
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
                  circles: _buildCircles(),
                  onTap: _onMapTap,
                  // Performance optimizations
                  liteModeEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  indoorViewEnabled: false,
                  trafficEnabled: false,
                  buildingsEnabled: false,
                ));
          });
        } catch (e) {
          print('GoogleMap widget hatası: $e');
          return _buildMapErrorWidget(e.toString());
        }
      },
    );
  }

  // Optimized Circles
  Set<Circle> _buildCircles() {
    if (mapController.currentPosition.value != null) {
      return {
        Circle(
          circleId: const CircleId('search_radius'),
          center: LatLng(
            mapController.currentPosition.value!.latitude,
            mapController.currentPosition.value!.longitude,
          ),
          radius: 500, // 500 metre yarıçap
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue.withOpacity(0.5),
          strokeWidth: 2,
        ),
      };
    }
    return {};
  }

  // Optimized Map Tap
  void _onMapTap(LatLng position) {
    mapController.addMarker(
      position,
      'Seçilen Konum',
      '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
    );
  }

  // Optimized Map Error Widget
  Widget _buildMapErrorWidget(String error) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('map_error'.tr),
            const SizedBox(height: 8),
            Text(error, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// Optimized Location Button
// Removed Location button as requested

// Optimized Zoom Controls
// Removed Zoom controls as requested
