import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Cache edilmiş konum bilgisi
  Position? _cachedPosition;
  DateTime? _lastLocationUpdate;
  static const Duration _locationCacheDuration = Duration(minutes: 5);

  /// Kullanıcının mevcut konumunu al
  /// Eğer izin yoksa veya GPS kapalıysa null döner
  Future<Position?> getCurrentLocation() async {
    try {
      // Önce cache'i kontrol et
      if (_cachedPosition != null && _lastLocationUpdate != null) {
        final timeDiff = DateTime.now().difference(_lastLocationUpdate!);
        if (timeDiff < _locationCacheDuration) {
          print(
              '[LOCATION SERVICE] Using cached location: ${_cachedPosition!.latitude}, ${_cachedPosition!.longitude}');
          return _cachedPosition;
        }
      }

      // Location permission kontrolü
      final permissionStatus = await _checkLocationPermission();
      if (permissionStatus != LocationPermission.always &&
          permissionStatus != LocationPermission.whileInUse) {
        print('[LOCATION SERVICE] Location permission denied');
        return null;
      }

      // GPS servis kontrolü
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('[LOCATION SERVICE] GPS service disabled');
        return null;
      }

      // Konum al
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        ),
      );

      // Cache'e kaydet
      _cachedPosition = position;
      _lastLocationUpdate = DateTime.now();

      print(
          '[LOCATION SERVICE] Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('[LOCATION SERVICE] Error getting location: $e');
      return null;
    }
  }

  /// Location permission kontrolü
  Future<LocationPermission> _checkLocationPermission() async {
    // Önce permission durumunu kontrol et
    PermissionStatus permission = await Permission.location.status;

    if (permission.isDenied) {
      // İzin verilmemişse izin iste
      print('[LOCATION SERVICE] Requesting location permission...');
      permission = await Permission.location.request();

      if (permission.isDenied) {
        print('[LOCATION SERVICE] Location permission denied by user');
        return LocationPermission.denied;
      }
    }

    if (permission.isPermanentlyDenied) {
      print('[LOCATION SERVICE] Location permission permanently denied');
      // Settings'e yönlendir
      await _showLocationPermissionDialog();
      return LocationPermission.deniedForever;
    }

    // Geolocator permission kontrolü
    LocationPermission geolocatorPermission =
        await Geolocator.checkPermission();

    if (geolocatorPermission == LocationPermission.denied) {
      geolocatorPermission = await Geolocator.requestPermission();
    }

    return geolocatorPermission;
  }

  /// Location permission dialog'u göster
  Future<void> _showLocationPermissionDialog() async {
    return Get.dialog(
      SizedBox(
        width: Get.width * 0.8,
        child: AlertDialog(
          backgroundColor: Theme.of(Get.context!).colorScheme.secondary,
          title: Column(
            children: [
              Container(
                width: 55,
                height: 55,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).colorScheme.onError,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  ImageAssets.locationIcon,
                  width: 24,
                  height: 24,
                  color: Theme.of(Get.context!).colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'location_permission_required'.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onBackground,
                ),
              ),
            ],
          ),
          content: Text(
            'location_permission_message'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Theme.of(Get.context!).colorScheme.onBackground,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('cancel'.tr),
            ),
            SizedBox(
              width: Get.width * 0.27,
              height: 40,
              child: ElevatedButton(
                style: AppTheme.primaryButtonStyle(),
                onPressed: () {
                  Get.back();
                  openAppSettings();
                },
                child: Text('settings'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Cache'i temizle
  void clearCache() {
    _cachedPosition = null;
    _lastLocationUpdate = null;
    print('[LOCATION SERVICE] Location cache cleared');
  }

  /// Konum bilgisi var mı kontrol et
  bool get hasLocation => _cachedPosition != null;

  /// Son bilinen konum
  Position? get lastKnownLocation => _cachedPosition;
}
