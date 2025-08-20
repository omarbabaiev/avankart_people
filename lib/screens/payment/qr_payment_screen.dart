import 'package:avankart_people/controllers/qr_payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPaymentScreen extends GetView<QrPaymentController> {
  const QrPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    Get.put(QrPaymentController());

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1C21),
      body: Center(
        child: SafeArea(
          child: Stack(
            children: [
              // İçerik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 56),

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
                          '${controller.balance.value}',
                          style: TextStyle(
    fontFamily: 'Poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )),

                    const SizedBox(height: 100),

                    // QR kod tarayıcı çerçevesi
                    SizedBox(
                      height: size.width * 0.7,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // QR kod

                          // Çerçeve kenarları - Sol üst
                          Positioned(
                            left: 0,
                            top: 0,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CustomPaint(
                                painter: CornerPainter(isTopLeft: true),
                              ),
                            ),
                          ),

                          // Çerçeve kenarları - Sağ üst
                          Positioned(
                            right: 0,
                            top: 0,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CustomPaint(
                                painter: CornerPainter(isTopRight: true),
                              ),
                            ),
                          ),

                          // Çerçeve kenarları - Sol alt
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CustomPaint(
                                painter: CornerPainter(isBottomLeft: true),
                              ),
                            ),
                          ),

                          // Çerçeve kenarları - Sağ alt
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CustomPaint(
                                painter: CornerPainter(isBottomRight: true),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

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
                      onPressed: controller.navigateToManualEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        minimumSize: const Size(180, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        'Əlnən daxil et',
                        style: TextStyle(
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
                          onTap: controller.toggleFlash,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFC107),
                              border: Border.all(
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
                right: 10,
                child: GestureDetector(
                  onTap: controller.onClose,
                  child: Container(
                    width: 40,
                    height: 40,
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
