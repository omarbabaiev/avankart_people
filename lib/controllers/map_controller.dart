import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/utils/vibration_util.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/companies_on_map_response.dart';
import '../services/companies_service.dart';
import '../services/location_service.dart';
import '../widgets/bottom_sheets/company_detail_bottom_sheet.dart';

class MapController extends GetxController {
  GoogleMapController? mapController;
  Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs;
  RxBool isLoading = true.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;
  RxBool isMapReady = false.obs;

  // Performance optimizations
  Timer? _locationTimer;
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  // Memory management
  bool _isDisposed = false;

  // Public getter for disposed state
  bool get isDisposed => _isDisposed;

  // Varsayılan konum (Bakü, Azerbaycan)
  final LatLng defaultLocation = const LatLng(40.3777, 49.8920);

  // Company markers
  RxList<CompanyOnMapModel> companies = <CompanyOnMapModel>[].obs;
  RxBool isLoadingCompanies = false.obs;

  // Custom marker cache
  final Map<String, BitmapDescriptor> _customMarkerCache = {};

  // Services
  final CompaniesService _companiesService = CompaniesService();
  final LocationService _locationService = LocationService();

  @override
  void onInit() {
    super.onInit();
    _isDisposed = false;

    // Performans için async başlatma
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        initializeMap();
        // Artık otomatik company yükleme yok, sadece harita başlatılıyor
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
      // Harita hazır olduğunu işaretle
      isMapReady.value = true;
    } catch (e) {
      print('Harita hazırlama hatası: $e');
    }
  }

  // Background'da konum alma - LocationService kullanarak
  void _getLocationInBackground() {
    if (_isDisposed) return;

    // Background'da konum al
    Future.microtask(() async {
      if (!_isDisposed) {
        await getCurrentLocation();
      }
    });
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

  // Konum izinlerini kontrol et (LocationService kullanarak)
  Future<void> checkLocationPermissions() async {
    // LocationService zaten izin kontrolü yapıyor, burada sadece getCurrentLocation çağırarak test ediyoruz
    await getCurrentLocation();
  }

  // Mevcut konumu al - LocationService kullanarak
  Future<void> getCurrentLocation() async {
    if (_isDisposed) return;

    try {
      // LocationService'den konum al
      final position = await _locationService.getCurrentLocation();

      if (!_isDisposed) {
        if (position != null) {
          currentPosition.value = position;
          _updateMapLocation();
          print(
              '[MAP CONTROLLER] Konum alındı: ${position.latitude}, ${position.longitude}');
        } else {
          currentPosition.value = null;
          print('[MAP CONTROLLER] Konum alınamadı');
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        print('[MAP CONTROLLER] Konum alma hatası: $e');
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

      // Harita hazır olduğunda ekrandaki karenin koordinatlarını al ve company'leri yükle
      _loadCompaniesForVisibleArea();
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

  // Ekranda görünen alanın koordinatlarını al ve company'leri yükle
  Future<void> _loadCompaniesForVisibleArea() async {
    if (_isDisposed || mapController == null) return;

    try {
      // Harita hazır olana kadar bekle
      await Future.delayed(const Duration(milliseconds: 500));

      if (_isDisposed || mapController == null) return;

      // Ekranda görünen alanın bounds'larını al
      final visibleRegion = await mapController!.getVisibleRegion();

      print(
          '[MAP CONTROLLER] Visible region: ${visibleRegion.northeast}, ${visibleRegion.southwest}');

      // Bounds'ları kullanarak company'leri yükle
      await _loadCompaniesWithBounds(
        northEastLat: visibleRegion.northeast.latitude,
        northEastLng: visibleRegion.northeast.longitude,
        southWestLat: visibleRegion.southwest.latitude,
        southWestLng: visibleRegion.southwest.longitude,
      );
    } catch (e) {
      print('[MAP CONTROLLER] Visible area company yükleme hatası: $e');
    }
  }

  // Bounds ile company'leri yükle - get-on-map API kullanarak
  Future<void> _loadCompaniesWithBounds({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  }) async {
    if (_isDisposed) return;

    try {
      isLoadingCompanies.value = true;

      print('[MAP CONTROLLER] Bounds ile company yükleme:');
      print('  NorthEast: $northEastLat, $northEastLng');
      print('  SouthWest: $southWestLat, $southWestLng');

      // get-on-map API'sini kullan
      final response = await _companiesService.getCompaniesOnMap(
        northEastLat: northEastLat,
        northEastLng: northEastLng,
        southWestLat: southWestLat,
        southWestLng: southWestLng,
      );

      if (response != null && !_isDisposed) {
        companies.value = response.data;
        print(
            '[MAP CONTROLLER] ${response.data.length} şirket bounds ile yüklendi');

        // Şirket marker'larını ekle
        await _addCompanyMarkers();
      }
    } catch (e) {
      print('[MAP CONTROLLER] Bounds ile şirket yükleme hatası: $e');
    } finally {
      if (!_isDisposed) {
        isLoadingCompanies.value = false;
      }
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
      markers.refresh(); // RxSet'i yenile
      update(); // UI'yı güncelle
    } catch (e) {
      print('Marker ekleme hatası: $e');
    }
  }

  // Tüm marker'ları temizle
  void clearMarkers() {
    if (_isDisposed) return;

    try {
      markers.clear();
      markers.refresh(); // RxSet'i yenile
      update(); // UI'yı güncelle
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

  // Harita kamerası hareket ettiğinde çağrılır
  void onCameraMove(CameraPosition position) {
    // Kamera hareket ederken hiçbir şey yapma, sadece log
    print('[MAP CONTROLLER] Kamera hareket ediyor: ${position.target}');
  }

  // Harita kamerası hareket durduğunda çağrılır
  void onCameraIdle() {
    if (_isDisposed) return;

    print('[MAP CONTROLLER] Kamera durdu, company\'leri yeniliyor...');

    // Debounce ile company'leri yeniden yükle
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (!_isDisposed) {
        print(
            '[MAP CONTROLLER] Debounce timer tamamlandı, company yükleme başlıyor...');
        _loadCompaniesForVisibleArea();
      }
    });
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

  // Örnek işletme marker'ları ekle (legacy) - Artık kullanılmıyor
  void addSampleMarkers() {
    // Artık örnek marker'lar kullanılmıyor, gerçek şirket verileri kullanılıyor
    print(
        'Örnek marker\'lar artık kullanılmıyor, gerçek şirket verileri kullanılıyor');
  }

  // Manuel olarak company'leri yenile (UI'dan çağrılabilir)
  Future<void> refreshCompanies() async {
    await _loadCompaniesForVisibleArea();
  }

  // Şirket marker'larını ekle
  Future<void> _addCompanyMarkers() async {
    if (_isDisposed || mapController == null) return;

    try {
      // Önce mevcut company marker'larını temizle
      _clearCompanyMarkers();

      // Yeni marker'ları toplu olarak oluştur
      final newMarkers = <Marker>{};

      for (final company in companies) {
        if (_isDisposed) break; // Dispose kontrolü

        if (company.locationPoint != null &&
            company.locationPoint!.coordinates.length >= 2) {
          final lat = company.locationPoint!.latitude;
          final lng = company.locationPoint!.longitude;

          // Geçerli koordinat kontrolü
          if (lat != 0.0 && lng != 0.0) {
            final marker = Marker(
              markerId: MarkerId('company_${company.id}'),
              position: LatLng(lat, lng),
              icon: await _getCustomCompanyMarkerIcon(company),
              onTap: () => _onCompanyMarkerTap(company),
            );

            newMarkers.add(marker);
            print(
                '[MAP CONTROLLER] Marker oluşturuldu: ${company.id} at $lat, $lng');
          }
        }
      }

      // Toplu güncelleme - RxSet'i yeniden ata
      if (!_isDisposed && mapController != null) {
        print(
            '[MAP CONTROLLER] Marker\'lar atanıyor: ${newMarkers.length} adet');
        markers.assignAll(newMarkers); // Tüm set'i değiştir
        print('[MAP CONTROLLER] ${markers.length} şirket marker\'ı eklendi');
        print('[MAP CONTROLLER] Marker set güncellendi, UI yenilenmeli');
      }
    } catch (e) {
      print('Şirket marker\'ları eklenirken hata: $e');
    }
  }

  // Company marker icon'u oluştur - Profile image circle avatar olarak
  Future<BitmapDescriptor> _getCustomCompanyMarkerIcon(
      CompanyOnMapModel company) async {
    final cacheKey =
        'company_${company.id}_${company.profileImagePath ?? 'default'}';

    // Cache'den kontrol et
    if (_customMarkerCache.containsKey(cacheKey)) {
      return _customMarkerCache[cacheKey]!;
    }

    try {
      // Profile image ile circle avatar marker oluştur
      final markerIcon = await _createCircleAvatarMarker(company);
      _customMarkerCache[cacheKey] = markerIcon;
      return markerIcon;
    } catch (e) {
      print('Circle avatar marker oluşturulurken hata: $e');
      // Hata durumunda default marker döndür
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  // Profile image ile circle avatar marker oluştur - 2.4 kat küçültülmüş
  Future<BitmapDescriptor> _createCircleAvatarMarker(
      CompanyOnMapModel company) async {
    try {
      print(
          '[MAP CONTROLLER] Circle avatar marker oluşturuluyor: ${company.id}');

      // Circle avatar boyutları (2.4 kat küçültülmüş)
      const double avatarSize = 40.0; // 2.4 kat küçültülmüş
      const double borderWidth = 3.0;
      const double totalSize = avatarSize + (borderWidth * 2);

      // Canvas oluştur
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);

      // Profile image'ı yükle
      ui.Image? profileImage = await _loadProfileImage(company);

      // Background circle çiz (border için)
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(totalSize / 2, totalSize / 2),
        avatarSize / 2 + borderWidth,
        borderPaint,
      );

      // Profile image varsa çiz
      if (profileImage != null) {
        // Circle clip path oluştur
        final clipPath = Path()
          ..addOval(Rect.fromLTWH(
            borderWidth,
            borderWidth,
            avatarSize,
            avatarSize,
          ));

        canvas.save();
        canvas.clipPath(clipPath);

        // Profile image'ı circle içine çiz
        canvas.drawImageRect(
          profileImage,
          Rect.fromLTWH(0, 0, profileImage.width.toDouble(),
              profileImage.height.toDouble()),
          Rect.fromLTWH(borderWidth, borderWidth, avatarSize, avatarSize),
          Paint(),
        );

        canvas.restore();
      } else {
        // Default placeholder çiz
        final placeholderPaint = Paint()
          ..color = Colors.grey.shade300
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(totalSize / 2, totalSize / 2),
          avatarSize / 2,
          placeholderPaint,
        );

        // "?" işareti çiz
        final textPainter = TextPainter(
          text: const TextSpan(
            text: '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            (totalSize - textPainter.width) / 2,
            (totalSize - textPainter.height) / 2,
          ),
        );
      }

      // Picture'i bitmap'e çevir
      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(totalSize.toInt(), totalSize.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final uint8List = byteData!.buffer.asUint8List();

      print('[MAP CONTROLLER] Circle avatar marker başarıyla oluşturuldu');
      return BitmapDescriptor.bytes(uint8List);
    } catch (e) {
      print('[MAP CONTROLLER] Circle avatar marker oluşturulurken hata: $e');
      // Hata durumunda default marker döndür
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  // Profile image'ı yükle (network veya default)
  Future<ui.Image?> _loadProfileImage(CompanyOnMapModel company) async {
    try {
      // Önce network image'ı dene
      if (company.profileImagePath != null &&
          company.profileImagePath!.isNotEmpty) {
        final imageUrl =
            'https://merchant.avankart.com/${company.profileImagePath}';
        print('[MAP CONTROLLER] Network profile image yükleniyor: $imageUrl');

        final networkImage = await _loadNetworkImage(imageUrl);
        if (networkImage != null) {
          return networkImage;
        }
      }

      // Network image yüklenemezse default logo kullan
      print('[MAP CONTROLLER] Default logo kullanılıyor');
      return await _loadDefaultLogo();
    } catch (e) {
      print('[MAP CONTROLLER] Profile image yüklenirken hata: $e');
      return null;
    }
  }

  // Network image yükle (cached)
  Future<ui.Image?> _loadNetworkImage(String imageUrl) async {
    try {
      // flutter_cache_manager kullanarak image'ı cache'den veya network'ten yükle
      final file = await DefaultCacheManager().getSingleFile(imageUrl);

      if (await file.exists()) {
        print(
            '[MAP CONTROLLER] Network image cache\'den yüklendi: ${file.path}');
        final bytes = await file.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        return frame.image;
      } else {
        print('[MAP CONTROLLER] Network image dosyası bulunamadı');
      }
    } catch (e) {
      print('[MAP CONTROLLER] Network image yüklenirken hata: $e');
    }
    return null;
  }

  // Default logo yükle
  Future<ui.Image?> _loadDefaultLogo() async {
    try {
      print('[MAP CONTROLLER] Default logo yükleniyor...');
      final ByteData data = await rootBundle.load(ImageAssets.png_logo);
      final Uint8List bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      print('[MAP CONTROLLER] Default logo başarıyla yüklendi');
      return frame.image;
    } catch (e) {
      print('[MAP CONTROLLER] Default logo yüklenirken hata: $e');
      return null;
    }
  }

  // Company marker'larını temizle
  void _clearCompanyMarkers() {
    if (_isDisposed) return;

    try {
      // Tüm marker'ları temizle (artık sadece company marker'ları var)
      print(
          '[MAP CONTROLLER] Marker\'lar temizleniyor, önceki sayı: ${markers.length}');
      markers.clear();
      markers.refresh(); // RxSet'i yenile
      update(); // UI'yı güncelle
      print(
          '[MAP CONTROLLER] Marker\'lar temizlendi, yeni sayı: ${markers.length}');

      // Cache'i optimize et - sadece son 50 marker'ı tut
      if (_customMarkerCache.length > 50) {
        final cacheKeys = _customMarkerCache.keys.toList();
        final keysToRemove = cacheKeys.take(cacheKeys.length - 50);
        for (final key in keysToRemove) {
          _customMarkerCache.remove(key);
        }
        print(
            '[MAP CONTROLLER] Marker cache optimize edildi: ${_customMarkerCache.length} marker kaldı');
      }
    } catch (e) {
      print('Company marker\'ları temizlenirken hata: $e');
    }
  }

  // Company marker'a tıklandığında
  void _onCompanyMarkerTap(CompanyOnMapModel company) {
    if (_isDisposed) return;

    try {
      // Önce company card request'i at
      _handleCompanyCardRequest(company);
    } catch (e) {
      print('Şirket marker tıklama hatası: $e');
    }
  }

  // Company card request'i işle
  Future<void> _handleCompanyCardRequest(CompanyOnMapModel company) async {
    try {
      // Şirket kartı seçimi - haptic feedback
      VibrationUtil.lightVibrate();

      print(
          '[MAP CONTROLLER] Company card request başlatılıyor: ${company.id}');

      // Company detail API request'i at
      final companyDetailResponse =
          await _companiesService.getCompanyDetails(muessiseId: company.id);

      if (companyDetailResponse != null && companyDetailResponse.success) {
        print('[MAP CONTROLLER] Company detail başarıyla alındı');
        // CompanyDetailScreen'i bottom sheet olarak aç
        _showCompanyDetailBottomSheet(company, companyDetailResponse);
      } else {
        print('[MAP CONTROLLER] Company detail alınamadı');
        // Hata durumunda sadece company bilgisi ile aç
        _showCompanyDetailBottomSheet(company, null);
      }
    } catch (e) {
      print('[MAP CONTROLLER] Company card request hatası: $e');
      // Hata durumunda sadece company bilgisi ile aç
      _showCompanyDetailBottomSheet(company, null);
    }
  }

  // CompanyDetailScreen'i bottom sheet olarak göster
  void _showCompanyDetailBottomSheet(
      CompanyOnMapModel company, dynamic companyDetailResponse) {
    // Özel bottom sheet'i aç
    Get.bottomSheet(
      CompanyDetailBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 1,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );

    // Arguments'ı global olarak set et
    _setGlobalArguments(company, companyDetailResponse);
  }

  // Global arguments set et
  void _setGlobalArguments(
      CompanyOnMapModel company, dynamic companyDetailResponse) {
    // GetX'in global state'ini kullan
    final arguments = {
      'company_id': company.id,
      'company': company,
      'company_detail': companyDetailResponse,
    };

    print('[MAP CONTROLLER] Setting global arguments: $arguments');
    Get.put(arguments, tag: 'company_detail_arguments');
  }

  @override
  void onClose() {
    _isDisposed = true;
    _locationTimer?.cancel();
    _debounceTimer?.cancel();

    // Güvenli dispose
    try {
      // Önce marker'ları temizle
      markers.clear();

      // Cache'i temizle
      _customMarkerCache.clear();

      // Sonra map controller'ı dispose et
      if (mapController != null) {
        mapController!.dispose();
      }
    } catch (e) {
      print('Map controller dispose hatası: $e');
    } finally {
      mapController = null;
    }

    super.onClose();
  }
}
