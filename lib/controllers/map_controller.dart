import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'dart:async';

class MapController extends GetxController {
  GoogleMapController? mapController;
  Rx<Position?> currentPosition = Rx<Position?>(null);
  Set<Marker> markers = <Marker>{}.obs;
  RxBool isLoading = true.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;
  RxBool isMapReady = false.obs;

  // Performance optimizations
  Timer? _locationTimer;
  Timer? _debounceTimer;
  Position? _cachedPosition;
  DateTime? _lastLocationUpdate;
  static const Duration _locationCacheDuration = Duration(minutes: 5);
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  // Memory management
  bool _isDisposed = false;

  // Public getter for disposed state
  bool get isDisposed => _isDisposed;

  // Varsayılan konum (Bakü, Azerbaycan)
  final LatLng defaultLocation = const LatLng(40.3777, 49.8920);

  @override
  void onInit() {
    super.onInit();
    _isDisposed = false;

    // Performans için async başlatma
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        initializeMap();
      }
    });
  }

  // Harita başlatma - Optimized
  Future<void> initializeMap() async {
    if (_isDisposed) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Önce haritayı hazırla, sonra konum al
      await _prepareMap();

      // Konum alma işlemini background'da yap
      _getLocationInBackground();
    } catch (e) {
      if (!_isDisposed) {
        print('Harita başlatma hatası: $e');
        hasError.value = true;
        errorMessage.value = 'Harita başlatılamadı: $e';
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  // Harita hazırlama - Optimized
  Future<void> _prepareMap() async {
    if (_isDisposed) return;

    try {
      // Örnek marker'ları ekle (daha hızlı)
      _addSampleMarkersOptimized();

      // Harita hazır olduğunu işaretle
      isMapReady.value = true;
    } catch (e) {
      print('Harita hazırlama hatası: $e');
    }
  }

  // Background'da konum alma - Optimized
  void _getLocationInBackground() {
    if (_isDisposed) return;

    // Eğer cache'de güncel konum varsa kullan
    if (_isLocationCacheValid()) {
      currentPosition.value = _cachedPosition;
      _updateMapLocation();
      return;
    }

    // Background'da konum al
    Future.microtask(() async {
      if (!_isDisposed) {
        await getCurrentLocation();
      }
    });
  }

  // Cache kontrolü
  bool _isLocationCacheValid() {
    if (_cachedPosition == null || _lastLocationUpdate == null) {
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(_lastLocationUpdate!);
    return difference < _locationCacheDuration;
  }

  // Harita konumunu güncelle - Debounced with error handling
  void _updateMapLocation() {
    if (_isDisposed || mapController == null || currentPosition.value == null) {
      return;
    }

    // Debounce konum güncellemelerini
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      if (!_isDisposed &&
          mapController != null &&
          currentPosition.value != null) {
        _safeAnimateCamera(
          LatLng(currentPosition.value!.latitude,
              currentPosition.value!.longitude),
        );
      }
    });
  }

  // iOS için özel başlatma - Optimized
  Future<void> _initializeForIOS() async {
    if (_isDisposed) return;

    try {
      // Konum izinlerini kontrol et (daha hızlı)
      await _checkLocationPermissionsOptimized();

      // Örnek marker'ları ekle
      _addSampleMarkersOptimized();

      // Mevcut konumu al (cache'den)
      if (_isLocationCacheValid()) {
        currentPosition.value = _cachedPosition;
      } else {
        await getCurrentLocation();
      }
    } catch (e) {
      print('iOS başlatma hatası: $e');
      // Hata olsa bile haritayı göster
      _addSampleMarkersOptimized();
    }
  }

  // Android için özel başlatma - Optimized
  Future<void> _initializeForAndroid() async {
    if (_isDisposed) return;

    try {
      // Konum izinlerini kontrol et
      await _checkLocationPermissionsOptimized();

      // Örnek marker'ları ekle
      _addSampleMarkersOptimized();

      // Mevcut konumu al
      if (_isLocationCacheValid()) {
        currentPosition.value = _cachedPosition;
      } else {
        await getCurrentLocation();
      }
    } catch (e) {
      print('Android başlatma hatası: $e');
      _addSampleMarkersOptimized();
    }
  }

  // Optimized konum izin kontrolü
  Future<void> _checkLocationPermissionsOptimized() async {
    if (_isDisposed) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Konum servisleri kapalı');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Konum izni reddedildi');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Konum izinleri kalıcı olarak reddedildi');
        return;
      }
    } catch (e) {
      print('Konum izin kontrolü hatası: $e');
    }
  }

  // Konum izinlerini kontrol et
  Future<void> checkLocationPermissions() async {
    await _checkLocationPermissionsOptimized();
  }

  // Mevcut konumu al - Optimized with throttling
  Future<void> getCurrentLocation() async {
    if (_isDisposed) return;

    try {
      // Cache kontrolü
      if (_isLocationCacheValid()) {
        currentPosition.value = _cachedPosition;
        _updateMapLocation();
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Konum servisleri kapalı');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Konum izni reddedildi');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Konum izinleri kalıcı olarak reddedildi');
        return;
      }

      // iOS için daha uzun timeout
      int timeoutSeconds = Platform.isIOS ? 8 : 6; // Further reduced timeout

      // Timeout ile konum al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Reduced accuracy for speed
        timeLimit: Duration(seconds: timeoutSeconds),
      ).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          throw Exception('Konum alma zaman aşımı');
        },
      );

      if (!_isDisposed) {
        // Cache'e kaydet
        _cachedPosition = position;
        _lastLocationUpdate = DateTime.now();
        currentPosition.value = position;

        // Haritayı güncelle
        _updateMapLocation();
      }
    } catch (e) {
      if (!_isDisposed) {
        print('Konum alınamadı: $e');
        currentPosition.value = null;
      }
    }
  }

  // Harita controller'ını ayarla - Optimized with error handling
  void onMapCreated(GoogleMapController controller) {
    if (_isDisposed) return;

    try {
      mapController = controller;

      // Eğer konum varsa hemen güncelle - with safety check
      if (currentPosition.value != null && !_isDisposed) {
        _safeAnimateCamera(
          LatLng(currentPosition.value!.latitude,
              currentPosition.value!.longitude),
        );
      }
    } catch (e) {
      print('Harita controller oluşturma hatası: $e');
    }
  }

  // Güvenli kamera animasyonu
  void _safeAnimateCamera(LatLng position) {
    if (_isDisposed || mapController == null) return;

    try {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(position),
      );
    } catch (e) {
      print('Kamera animasyon hatası: $e');
      // Hata durumunda controller'ı null yap
      mapController = null;
    }
  }

  // Marker ekle - Optimized with throttling
  void addMarker(LatLng position, String title, String snippet,
      {Color? markerColor}) {
    if (_isDisposed) return;

    try {
      final marker = Marker(
        markerId: MarkerId(title),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          markerColor == Colors.red
              ? BitmapDescriptor.hueRed
              : markerColor == Colors.blue
                  ? BitmapDescriptor.hueBlue
                  : markerColor == Colors.green
                      ? BitmapDescriptor.hueGreen
                      : markerColor == Colors.orange
                          ? BitmapDescriptor.hueOrange
                          : markerColor == Colors.purple
                              ? BitmapDescriptor.hueViolet
                              : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: title,
          snippet: snippet,
        ),
      );

      // Batch update için
      markers.add(marker);
      update();
    } catch (e) {
      print('Marker ekleme hatası: $e');
    }
  }

  // Tüm marker'ları temizle
  void clearMarkers() {
    if (_isDisposed) return;

    try {
      markers.clear();
      update();
    } catch (e) {
      print('Marker temizleme hatası: $e');
    }
  }

  // Haritayı belirli konuma taşı - Optimized
  void moveToLocation(LatLng location) {
    if (_isDisposed || mapController == null) return;

    try {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(location),
      );
    } catch (e) {
      print('Harita taşıma hatası: $e');
    }
  }

  // Yakınlaştır - Optimized
  void zoomIn() {
    if (_isDisposed || mapController == null) return;

    try {
      mapController!.animateCamera(
        CameraUpdate.zoomIn(),
      );
    } catch (e) {
      print('Yakınlaştırma hatası: $e');
    }
  }

  // Uzaklaştır - Optimized
  void zoomOut() {
    if (_isDisposed || mapController == null) return;

    try {
      mapController!.animateCamera(
        CameraUpdate.zoomOut(),
      );
    } catch (e) {
      print('Uzaklaştırma hatası: $e');
    }
  }

  // Optimized örnek marker'lar - Batch processing
  void _addSampleMarkersOptimized() {
    if (_isDisposed) return;

    try {
      // Batch marker ekleme
      final newMarkers = <Marker>{};

      // ÖZSÜT marker'ı (siyah)
      newMarkers.add(Marker(
        markerId: const MarkerId('ÖZSÜT'),
        position: const LatLng(40.3777, 49.8920),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: 'ÖZSÜT',
          snippet: '—1938—',
        ),
      ));

      // BORANI marker'ı (beyaz)
      newMarkers.add(Marker(
        markerId: const MarkerId('BORANI'),
        position: const LatLng(40.3780, 49.8925),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(
          title: 'BORANI',
          snippet: 'Restoran',
        ),
      ));

      // Sightglass Coffee marker'ı (turuncu)
      newMarkers.add(Marker(
        markerId: const MarkerId('Sightglass Coffee'),
        position: const LatLng(40.3775, 49.8915),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
          title: 'Sightglass Coffee',
          snippet: 'Kafe',
        ),
      ));

      // Costco Wholesale marker'ı (mavi)
      newMarkers.add(Marker(
        markerId: const MarkerId('Costco Wholesale'),
        position: const LatLng(40.3785, 49.8930),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Costco Wholesale',
          snippet: 'Market',
        ),
      ));

      // Best Buy marker'ı (mavi)
      newMarkers.add(Marker(
        markerId: const MarkerId('Best Buy'),
        position: const LatLng(40.3770, 49.8910),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Best Buy',
          snippet: 'Elektronik',
        ),
      ));

      // Batch update
      markers.addAll(newMarkers);
      update();
    } catch (e) {
      print('Örnek marker ekleme hatası: $e');
    }
  }

  // Örnek işletme marker'ları ekle (legacy)
  void addSampleMarkers() {
    _addSampleMarkersOptimized();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _locationTimer?.cancel();
    _debounceTimer?.cancel();

    // Güvenli dispose
    try {
      mapController?.dispose();
    } catch (e) {
      print('Map controller dispose hatası: $e');
    } finally {
      mapController = null;
    }

    super.onClose();
  }
}
