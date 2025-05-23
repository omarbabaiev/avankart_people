import 'dart:ui';

import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/benefits_controller.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class BenefitsScreen extends GetView<BenefitsController> {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    Get.put(BenefitsController());

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.primaryTextColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.primaryTextColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryTextColor,
        centerTitle: true,
        toolbarHeight: 70,
        leadingWidth: 70,
        leading: IconButton.filledTonal(
          icon: Icon(Icons.arrow_back, size: 24, color: AppTheme.white),
          onPressed: () => Get.back(),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.white.withOpacity(0.2),
            fixedSize: Size(44, 44),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Xərclədikcə Qazan',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Qazanılıb 2/24',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.white.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  thickness: .05,
                ),
                TabBar(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0,
                  ),
                  controller: controller.tabController,
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  tabs: const [
                    Tab(text: 'Yemək'),
                    Tab(text: 'Yanacaq'),
                    Tab(text: 'Hədiyyə'),
                    Tab(text: 'Market'),
                    Tab(text: 'Biznes'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating gradient background
          AnimatedBuilder(
            animation: controller.rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: controller.rotationController.value * 2 * 3.14159,
                child: Image.asset(
                  ImageAssets.png_logo,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: SweepGradient(
                center: Alignment.center,
                colors: [
                  AppTheme.primaryTextColor,
                  AppTheme.primaryTextColor.withOpacity(0.6),
                  AppTheme.primaryTextColor.withOpacity(0.2),
                  AppTheme.primaryTextColor.withOpacity(0.1),
                ],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryTextColor.withOpacity(0.2),
              ),
            ),
          ),
          // Tab Content
          TabBarView(
            controller: controller.tabController,
            children: [
              _buildBenefitsList(),
              _buildBenefitsList(),
              _buildBenefitsList(),
              _buildBenefitsList(),
              _buildBenefitsList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.8,
        ),
        itemCount: 20,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => controller.showBenefitDialog(context, index),
            child: Column(
              children: [
                Image.asset("assets/images/Silver.png", height: 60),
                SizedBox(height: 8),
                Text(
                  '20 dəfə ye ${index + 1} qazan',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
