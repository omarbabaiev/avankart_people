import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/qr_payment_controller.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrPaymentScreen extends StatefulWidget {
  const QrPaymentScreen({super.key});

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen> with WidgetsBindingObserver {
  MobileScannerController? scannerController;
  bool isFlashOn = false;
  bool isScanning = true;
  late QrPaymentController qrPaymentController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Controller'ı başlat
    qrPaymentController = Get.put(QrPaymentController());
    scannerController = MobileScannerController();

    // Flash state'ini controller ile senkronize et
    isFlashOn = qrPaymentController.isFlashOn.value;
    
    // Scanner'ı yeniden başlatma isteğini dinle
    ever(qrPaymentController.shouldRestartScanning, (bool _) {
      if (mounted) {
        _restartScanning();
      }
    });
    
    // Route değişikliklerini dinle - ekrana geri döndüğünde scanner'ı başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRestartScanner();
    });
  }
  
  void _checkAndRestartScanner() {
    // Eğer scanner durmuşsa ve QR status pending ise, yeniden başlat
    if (!isScanning && qrPaymentController.qrStatus.value == 'pending') {
      _restartScanning();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scannerController?.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Uygulama ön plana döndüğünde scanner'ı yeniden başlat
    if (state == AppLifecycleState.resumed) {
      _restartScanning();
    }
  }
  
  void _restartScanning() {
    if (mounted) {
      setState(() {
        isScanning = true;
      });
      // Scanner controller'ı yeniden başlat
      scannerController?.stop();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && scannerController != null) {
          scannerController!.start();
        }
      });
      debugPrint('[QR PAYMENT SCREEN] Scanning restarted');
    }
  }

  void _toggleFlash() async {
    debugPrint('[QR PAYMENT SCREEN] ===== TOGGLE FLASH =====');
    debugPrint('[QR PAYMENT SCREEN] scannerController: $scannerController');
    debugPrint('[QR PAYMENT SCREEN] Current isFlashOn: $isFlashOn');

    if (scannerController != null) {
      try {
        await scannerController!.toggleTorch();
        debugPrint(
            '[QR PAYMENT SCREEN] Scanner Controller flash toggled successfully');

        setState(() {
          isFlashOn = !isFlashOn;
        });

        // Controller'ın state'ini de güncelle
        final controller = Get.find<QrPaymentController>();
        controller.isFlashOn.value = isFlashOn;

        debugPrint('[QR PAYMENT SCREEN] Flash toggled: $isFlashOn');
        debugPrint(
            '[QR PAYMENT SCREEN] Controller flash state: ${controller.isFlashOn.value}');
      } catch (e) {
        debugPrint('[QR PAYMENT SCREEN] Error toggling flash: $e');
      }
    } else {
      debugPrint('[QR PAYMENT SCREEN] QR Controller is null!');
    }
    debugPrint('[QR PAYMENT SCREEN] =========================');
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QrPaymentController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1C21),
      body: Center(
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              MobileScanner(
                controller: scannerController!,
                onDetect: (capture) {
                  if (isScanning && capture.barcodes.isNotEmpty) {
                    final barcode = capture.barcodes.first;
                    if (barcode.rawValue != null) {
                      debugPrint(
                          '[QR PAYMENT SCREEN] QR Code scanned: ${barcode.rawValue}');

                      setState(() {
                        isScanning = false;
                      });

                      // QR kod tespit edildi, controller'a gönder
                      qrPaymentController
                          .checkQrCode(barcode.rawValue!.toUpperCase());
                    }
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 70, right: 50, left: 50),
                child: Lottie.asset(
                  ImageAssets.qrPayment,
                  width: 215,
                ),
              ),
              // İçerik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 70),

                    // Kart adı
                    Obx(() => Text(
                          controller.cardName.value,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        )),

                    const SizedBox(height: 4),

                    // Bakiye
                    Obx(() => Text(
                          '${controller.balance.value.toStringAsFixed(2)} ${AppTheme.currencySymbol}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )),

                    const SizedBox(height: 100),

                    const Spacer(),

                    // Alt mesaj
                    Text(
                      'cant_scan_qr_code'.tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Manuel giriş butonu
                    ElevatedButton(
                      onPressed: controller.showManualQrInput,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        minimumSize: const Size(180, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        'manual_entry'.tr,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Flaş butonu
                    Obx(() => GestureDetector(
                          onTap: _toggleFlash,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFC107),
                              border: Border.all(
                                strokeAlign: BorderSide.strokeAlignOutside,
                                color: const Color(0xFFFFD54F),
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              controller.isFlashOn.value
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        )),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Kapat butonu - sağ üst köşe
              Positioned(
                top: 10,
                right: 15,
                child: GestureDetector(
                  onTap: controller.onClose,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Köşe çizici
class CornerPainter extends CustomPainter {
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  CornerPainter({
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double length = 20;

    if (isTopLeft) {
      // L şeklinde sol üst köşe
      canvas.drawLine(Offset(0, length), Offset(0, 0), paint);
      canvas.drawLine(Offset(0, 0), Offset(length, 0), paint);
    } else if (isTopRight) {
      // ┐ şeklinde sağ üst köşe
      canvas.drawLine(
          Offset(size.width - length, 0), Offset(size.width, 0), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);
    } else if (isBottomLeft) {
      // └ şeklinde sol alt köşe
      canvas.drawLine(
          Offset(0, size.height - length), Offset(0, size.height), paint);
      canvas.drawLine(
          Offset(0, size.height), Offset(length, size.height), paint);
    } else if (isBottomRight) {
      // ┘ şeklinde sağ alt köşe
      canvas.drawLine(Offset(size.width, size.height - length),
          Offset(size.width, size.height), paint);
      canvas.drawLine(Offset(size.width, size.height),
          Offset(size.width - length, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
