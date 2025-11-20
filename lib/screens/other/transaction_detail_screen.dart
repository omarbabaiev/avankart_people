import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/models/card_models.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/conts_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticket_widget/ticket_widget.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Color? cardColor;
  final String? cardTitle;
  final String? cardIcon;
  final String? cardDescription;

  const TransactionDetailScreen({
    Key? key,
    this.cardColor,
    this.cardTitle,
    this.cardIcon,
    this.cardDescription,
  }) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CardTransactionDetails? _transactionDetail;

  // Computed getters for payment data
  bool get isSuccess =>
      _transactionDetail?.status.toLowerCase() == 'success' ||
      _transactionDetail?.status.toLowerCase() == 'completed';

  String? get errorMessage =>
      _transactionDetail?.status.toLowerCase() == 'failed' ||
              _transactionDetail?.status.toLowerCase() == 'cancelled'
          ? _transactionDetail?.status
          : null;

  // Formatlanmış tarih
  String get formattedDate {
    if (_transactionDetail == null) return '';
    final date = _transactionDetail!.date ?? _transactionDetail!.createdAt;
    if (date != null) {
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
    }
    return '';
  }

  // Model'den direkt veri çekme metodları
  String get amountText =>
      _transactionDetail?.amount.abs().toStringAsFixed(2) ?? '0.00';
  String get currency =>
      _transactionDetail?.currency ?? AppTheme.currencySymbol;
  String get transactionId =>
      _transactionDetail?.transactionId ?? 'TRX-XXXXXXXXXXXXXX';
  String get cardType =>
      _transactionDetail?.category ??
      _transactionDetail?.muessiseCategory ??
      'Yemək';
  String get receivingInstitution =>
      _transactionDetail?.muessiseName ?? 'Özsüt Restoran';
  String get merchantId {
    // "to" objesi içindeki _id'yi al (Ödənişi alan ID)
    if (_transactionDetail?.to != null &&
        _transactionDetail!.to is Map<String, dynamic>) {
      return _transactionDetail!.to!['_id'] ?? 'RO-321';
    }
    return 'RO-321';
  }

  String get payerId => _transactionDetail?.from ?? 'RO-321';
  double? get cashback => _transactionDetail?.cashback;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // UI'yi güncellemek için setState çağır
      });
    });

    // Get.arguments'tan transaction detail'i al
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      final transactionDetailData = arguments['transactionDetail'];
      if (transactionDetailData != null) {
        if (transactionDetailData is CardTransactionDetails) {
          _transactionDetail = transactionDetailData;
        } else if (transactionDetailData is Map<String, dynamic>) {
          _transactionDetail =
              CardTransactionDetails.fromJson(transactionDetailData);
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.cardColor ?? Colors.blue,
      ),
      child: Stack(
        children: [
          FadeInImage(
            placeholder: AssetImage(ImageAssets.background),
            image: AssetImage(ImageAssets.background),
            fit: BoxFit.cover,
          ),
          SafeArea(
            bottom: false,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  // Header
                  _buildHeader(context),
                  // Main Content
                  Expanded(
                    child: _buildMainContent(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Status bar
          SizedBox(height: 20),
          // Navigation and title
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  _transactionDetail?.muessiseName ?? 'transaction_detail'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.98,
      minChildSize: 0.98,
      maxChildSize: 0.98,
      snap: true,
      snapAnimationDuration: const Duration(milliseconds: 1000),
      builder: (BuildContext context, ScrollController scrollController) {
        return Hero(
          tag: Get.arguments?['heroTag'] ?? 'card_header',
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 30),
                        // Success/Failure Icon
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSuccess
                                ? Color(0xFF10B981)
                                    .withOpacity(0.1) // Light green
                                : Color(0xFFEF4444)
                                    .withOpacity(0.1), // Light red
                          ),
                          child: Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSuccess
                                    ? Color(0xFF10B981) // Green
                                    : Color(0xFFEF4444), // Red
                              ),
                              child: Icon(
                                isSuccess ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        // Title
                        Text(
                          isSuccess
                              ? 'payment_success'.tr
                              : 'payment_failed'.tr,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground, // Dark gray
                            fontFamily: 'Poppins',
                          ),
                        ),

                        SizedBox(height: 8),

                        // Subtitle
                        Text(
                          isSuccess
                              ? 'payment_success_description'.tr
                              : (errorMessage ??
                                  'payment_failed_description'.tr),
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .unselectedWidgetColor, // Medium gray
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 20),

                        // Payment Details Card
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary, // Very light gray
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor, // Light border
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow('amount'.tr,
                                  '+$amountText $currency', true, context),
                              SizedBox(height: 12),
                              _buildStatusRow(),
                              SizedBox(height: 12),
                              Container(
                                height: 1,
                                color: Color(0xFFE5E7EB),
                              ),
                              SizedBox(height: 12),
                              _buildDetailRow('transaction_id'.tr,
                                  transactionId, false, context),
                              _buildDetailRow(
                                  'card_type'.tr,
                                  cardType.isNotEmpty ? cardType : 'Yemək',
                                  false,
                                  context),
                              if (formattedDate.isNotEmpty) ...[
                                _buildDetailRow('payment_date'.tr,
                                    formattedDate, false, context),
                              ],
                              if (receivingInstitution.isNotEmpty) ...[
                                _buildDetailRow('merchant'.tr,
                                    receivingInstitution, false, context),
                              ],
                              _buildDetailRow(
                                  'merchant_id'.tr, merchantId, false, context),
                              _buildDetailRow(
                                  'payer_id'.tr, payerId, false, context),
                              if (cashback != null && cashback! > 0) ...[
                                _buildDetailRow(
                                    'cashback'.tr,
                                    '+${cashback!.toStringAsFixed(2)} $currency',
                                    false,
                                    context),
                              ],
                            ],
                          ),
                        ),

                        Spacer(),
                      ],
                    ),
                  ),
                  // Header buttons (Support and Share)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Row(
                      children: [
                        // Support button
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.support);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Icon(
                              Icons.headphones,
                              color: Theme.of(context).colorScheme.onBackground,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        // Share button
                        GestureDetector(
                          onTap: () {
                            _shareTransaction();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Icon(
                              Icons.share,
                              color: Theme.of(context).colorScheme.onBackground,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
      String label, String value, bool isAmount, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).unselectedWidgetColor, // Medium gray
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isAmount ? 16 : 13,
              color: Theme.of(context).colorScheme.onBackground, // Dark gray
              fontWeight: isAmount ? FontWeight.w600 : FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  // Ticket widget - Share üçün istifadə olunur
  Widget _buildTicketWidget(BuildContext context) {
    // Static LIGHT theme palette - Şəklə uyğun
    const Color bgLight = Colors.white; // Arxa plan ağ
    const Color ticketColor =
        Color(0xFFE8EAED); // Ticket-in özü boz/mavi-boz (şəkildəki kimi)
    const Color cardLight = Color(0xFFF5F6F7); // Ticket içi açıq boz
    const Color textPrimary = Color(0xFF1D222B);
    const Color textSecondary = Color(0xFF6B7280);
    const Color successBg = Color(0xFF10B981); // Yaşıl status
    const Color successFg = Colors.white;
    const Color errorBg = Color(0xFFEF4444);
    const Color errorFg = Colors.white;
    final bool ok = isSuccess;

    return Container(
      color: bgLight, // Arxa plan ağ
      child: Center(
        child: TicketWidget(
          color: ticketColor, // Ticket-in özü boz/mavi-boz
          width: 340,
          height: 600,
          isCornerRounded: false, // Border radius 0 (şəkildəki kimi)
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header - Şəkildəki kimi üst hissə
              Container(
                color: cardLight, // Ticket içi açıq boz
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    // Sol tərəfdə logo və amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(
                              ImageAssets.png_logo,
                              height: 24,
                              width: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Amount (böyüdülmüş)
                        Material(
                          child: Text(
                            '$amountText $currency',
                            style: const TextStyle(
                              color: textPrimary,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 32, // Böyüdüldü 28-dən 32-yə
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Merchant adı (şəkildəki kimi)
                        Material(
                          child: Text(
                            receivingInstitution.isNotEmpty
                                ? receivingInstitution.toUpperCase()
                                : 'AVANKART',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textSecondary,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Status chip (şəkildəki kimi yaşıl)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: ok ? successBg : errorBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              ok ? 'successful'.tr : 'failed'.tr,
                              style: TextStyle(
                                color: ok ? successFg : errorFg,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Yuxarı sağda mühür
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Image.asset(
                        ImageAssets.stamp,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              // Body - Detallar (şəkildəki kimi)
              Container(
                color: cardLight, // Ticket içi açıq boz
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashed line separator (şəkildəki kimi)
                    CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: DashedLinePainter(
                        color: const Color(0xFFD1D5DB),
                        strokeWidth: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Detallar (şəkildəki kimi sütunlar)
                    _ticketRowStatic('payment_date'.tr,
                        formattedDate.isNotEmpty ? formattedDate : '-'),
                    _ticketRowStatic('card_type'.tr, cardType),
                    _ticketRowStatic('transaction_id'.tr, transactionId),
                    _ticketRowStatic('merchant_id'.tr,
                        merchantId.isNotEmpty ? merchantId : '-'),
                    _ticketRowStatic(
                        'payer_id'.tr, payerId.isNotEmpty ? payerId : '-'),
                    _ticketRowStatic('paying_company'.tr, 'Avankart'),
                    if (cashback != null && cashback! > 0)
                      _ticketRowStatic('cashback'.tr,
                          '+${cashback!.toStringAsFixed(2)} $currency'),
                  ],
                ),
              ),
              const Spacer(),
              // Footer - Mavi bar və bank logosu (şəkildəki kimi)
              Container(
                color: AppTheme.primaryColor, // Mavi bar (şəkildəki kimi)
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sol tərəfdə logo və bank adı (şəkildəki kimi)
                    Image.asset(
                      ImageAssets.fullLogo,
                      height: 25,
                    ),
                    // Sağ tərəfdə telefon iconu (şəkildəki kimi)
                    Row(
                      children: [
                        const Icon(
                          Icons.headset_mic,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Material(
                          color: Colors.transparent,
                          child: Text(
                            ConstTexts.supportPhone,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
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
    );
  }

  Widget _ticketRowStatic(String label, String value) {
    const Color textPrimary = Color(0xFF1D222B);
    const Color textSecondary = Color(0xFF6B7280);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label (sol tərəf - şəkildəki kimi)
          Material(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: textSecondary,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Value (sağ tərəf - şəkildəki kimi)
          Flexible(
            child: Material(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 13,
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // (old _ticketRow removed)

  Widget _buildStatusRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'payment_status'.tr,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280), // Medium gray
              fontFamily: 'Poppins',
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSuccess
                  ? Color.fromARGB(24, 16, 185, 129) // Green
                  : Color.fromARGB(24, 239, 68, 68), // Red
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isSuccess ? 'successful'.tr : 'failed'.tr,
              style: TextStyle(
                fontSize: 13,
                color: isSuccess ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Share üçün ticket widget-i şəkil kimi paylaşır
  // _buildTicketWidget metodunu istifadə edir
  Future<void> _shareTransaction() async {
    try {
      if (_transactionDetail == null) return;

      // 1) Ticket'i geçici overlay'de görünməz render et
      final GlobalKey ticketKey = GlobalKey();
      final overlay = Overlay.of(context);
      final entry = OverlayEntry(
        builder: (_) => Container(
          color: Colors.white, // Arxa plan ağ (şəkildəki kimi)
          child: Center(
            child: RepaintBoundary(
              key: ticketKey,
              child: _buildTicketWidget(context), // Share üçün eyni widget
            ),
          ),
        ),
      );
      overlay.insert(entry);

      // 2) Frame tamamlanmasını gözlə
      await Future.delayed(const Duration(milliseconds: 50));
      await WidgetsBinding.instance.endOfFrame;

      // 3) RenderRepaintBoundary-dən şəkil çək
      final boundary = ticketKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        entry.remove();
        return;
      }
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      entry.remove();
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file =
          await File('${tempDir.path}/transaction_ticket_${transactionId}.png')
              .create();
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles([XFile(file.path)],
          text: 'transaction_detail'.tr);
    } catch (e) {
      // Fallback: yalnız mətn paylaş
      await Share.share(
          '${'transaction_detail'.tr}\n${'transaction_id'.tr}: $transactionId');
    }
  }
}

// Dashed line painter for separator
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedLinePainter({
    required this.color,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
