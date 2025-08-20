import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _introImages = [
    ImageAssets.frame1,
    ImageAssets.frame2,
    ImageAssets.frame3,
  ];

  final List<String> _introTexts = [
    'intro_text1'.tr,
    'intro_text2'.tr,
    'intro_text3'.tr,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: Get.height / 1.8,
              child: Stack(
                children: [
                  // Ana içerik
                  SizedBox(
                    height: Get.height / 1.7,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: _introImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: Get.width,
                          height: Get.height / 4,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FadeInImage(
                                placeholder: AssetImage(ImageAssets.fullLogo),
                                image: AssetImage(_introImages[index]),
                                fit: BoxFit.cover,
                              ).image,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Indicator
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _introTexts[_currentPage],
                textAlign: TextAlign.center,
                style: TextStyle(
    fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),

            // Text
            const SizedBox(height: 20),
            SizedBox(
              height: 17,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _introImages.length,
                  (index) => _currentPage == index
                      ? AnimatedContainer(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 6,
                          height: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          duration: Duration(milliseconds: 300),
                        )
                      : AnimatedContainer(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Theme.of(
                              context,
                            ).shadowColor.withOpacity(.5),
                          ),
                          duration: Duration(milliseconds: 300),
                        ),
                ),
              ),
            ),
            SizedBox(height: 40),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.login);
                },
                style: AppTheme.primaryButtonStyle(),
                child: Text(
                  'login'.tr,
                  style: AppTheme.buttonTextStyle
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  child: Text(
                    'create_account'.tr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
