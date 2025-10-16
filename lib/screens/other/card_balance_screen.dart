import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardBalanceScreen extends StatefulWidget {
  final Color? cardColor;
  final String? cardTitle;
  final String? cardIcon;
  final String? cardDescription;

  const CardBalanceScreen({
    Key? key,
    this.cardColor,
    this.cardTitle,
    this.cardIcon,
    this.cardDescription,
  }) : super(key: key);

  @override
  State<CardBalanceScreen> createState() => _CardBalanceScreenState();
}

class _CardBalanceScreenState extends State<CardBalanceScreen> {
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
              Text(
                'increment_card_balance'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Poppins',
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
          tag: Get.arguments?['heroTag'] ?? 'card_balance',
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Get.isDarkMode
                      ? Image.asset(
                          ImageAssets.temirdark,
                          width: 300,
                        )
                      : Image.asset(
                          ImageAssets.temir,
                          width: 300,
                        ),
                  SizedBox(height: 16),
                  Text(
                    'temir_isleri_aparilir'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'temir_isleri_aparilir_description'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Inter',
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
