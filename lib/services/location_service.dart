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
          debugPrint(
              '[LOCATION SERVICE] Using cached location: ${_cachedPosition!.latitude}, ${_cachedPosition!.longitude}');
          return _cachedPosition;
        }
      }

      // Location permission kontrolü
      final permissionStatus = await _checkLocationPermission();
      if (permissionStatus != LocationPermission.whileInUse &&
          permissionStatus != LocationPermission.always) {
        debugPrint('[LOCATION SERVICE] Location permission denied');
        return null;
      }

      // GPS servis kontrolü
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LOCATION SERVICE] GPS service disabled');
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

      debugPrint(
          '[LOCATION SERVICE] Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('[LOCATION SERVICE] Error getting location: $e');
      return null;
    }
  }

  /// Location permission kontrolü
  Future<LocationPermission> _checkLocationPermission() async {
    // Önce Geolocator ile izin durumunu kontrol et (daha güvenilir)
    LocationPermission geolocatorPermission =
        await Geolocator.checkPermission();

    // Eğer izin zaten verilmişse, diyalog gösterme ve direkt döndür
    if (geolocatorPermission == LocationPermission.whileInUse ||
        geolocatorPermission == LocationPermission.always) {
      debugPrint('[LOCATION SERVICE] Location permission already granted: $geolocatorPermission');
      return geolocatorPermission;
    }

    // İzin verilmemişse, permission_handler ile kontrol et
    PermissionStatus permission = await Permission.location.status;

    if (permission.isDenied) {
      // İzin verilmemişse izin iste
      debugPrint('[LOCATION SERVICE] Requesting location permission...');
      permission = await Permission.location.request();

      if (permission.isDenied) {
        debugPrint('[LOCATION SERVICE] Location permission denied by user');
        return LocationPermission.denied;
      }
    }

    // Permission_handler ile kalıcı red kontrolü
    if (permission.isPermanentlyDenied) {
      // Önce Geolocator ile tekrar kontrol et (iOS'ta bazen yanlış algılanabiliyor)
      geolocatorPermission = await Geolocator.checkPermission();
      
      // Eğer Geolocator izin verilmiş diyorsa, diyalog gösterme
      if (geolocatorPermission == LocationPermission.whileInUse ||
          geolocatorPermission == LocationPermission.always) {
        debugPrint('[LOCATION SERVICE] Location permission granted by Geolocator, ignoring permanently denied status');
        return geolocatorPermission;
      }
      
      // Gerçekten kalıcı olarak reddedilmişse, diyalog göster
      debugPrint('[LOCATION SERVICE] Location permission permanently denied');
      await _showLocationPermissionDialog();
      return LocationPermission.deniedForever;
    }

    // Son kontrol: Geolocator permission'ı tekrar al
    geolocatorPermission = await Geolocator.checkPermission();

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
          contentPadding: EdgeInsets.all(10),
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
            textAlign: TextAlign.center,
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
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(Get.context!).unselectedWidgetColor,
              ),
              child: Text('cancel'.tr),
            ),
            SizedBox(
              height: 40,
              width: Get.width * 0.4,
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
    debugPrint('[LOCATION SERVICE] Location cache cleared');
  }

  /// Konum bilgisi var mı kontrol et
  bool get hasLocation => _cachedPosition != null;

  /// Son bilinen konum
  Position? get lastKnownLocation => _cachedPosition;
}
