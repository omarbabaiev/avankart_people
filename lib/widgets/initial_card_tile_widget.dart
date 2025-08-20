import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class InitialCardTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const InitialCardTileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: value
          ? () => onChanged(false) // Kart aktifse, tıklandığında deaktif et
          : () => _cardDetailBottomSheet(
                // Kart aktif değilse bottom sheet aç
                context,
                title,
                subtitle,
                icon.toString(),
                color.toString(),
              ),
      child: Container(
        margin: EdgeInsets.only(top: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color,
              ),
              child: Icon(icon, color: Colors.black, size: 20),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Switch.adaptive(
              value: value,
              onChanged:
                  (value) {}, // Switch'i manuel olarak değiştirilemez yap
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _cardDetailBottomSheet(
    BuildContext context,
    String title,
    String subtitle,
    String icon,
    String color,
  ) {
    bool isTermsAccepted = false;
    bool isRulesAccepted = false;
    bool isSecondPage = false;
    final PageController _pageController = PageController();

    context.showPerformantBottomSheet(
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        context.buildBottomSheetHandle(),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: PageView(
                            controller: _pageController,
                            physics: NeverScrollableScrollPhysics(),
                            onPageChanged: (page) {
                              setState(() {
                                isSecondPage = page == 1;
                              });
                            },
                            children: [
                              // İlk sayfa - Aktivasiya şərtləri
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: this.color,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Transform.rotate(
                                        angle: 3.14,
                                        child: Icon(
                                          this.icon,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onBackground,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onBackground,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        subtitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          color: Theme.of(
                                            context,
                                          ).unselectedWidgetColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Divider(
                                      color: Theme.of(context).splashColor,
                                      thickness: 0.5,
                                    ),
                                    SizedBox(height: 15),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Yemək kartının aktivasiya şərtləri",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Theme.of(context).splashColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    _buildExpansionTileCard(
                                      context: context,
                                      title:
                                          "Yemək kartının aktivasiya şərtləri",
                                      content:
                                          "Yemək kartının aktivasiya şərtləri",
                                    ),
                                    Row(
                                      children: [
                                        AppTheme.adaptiveCheckbox(
                                          value: isTermsAccepted,
                                          onChanged: (value) {
                                            setState(() {
                                              isTermsAccepted = value ?? false;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Şərtləri oxudum və qəbul etdim",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onBackground,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // İkinci sayfa - İstifadə qaydaları
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: this.color,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Transform.rotate(
                                        angle: 3.14,
                                        child: Icon(
                                          this.icon,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onBackground,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onBackground,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        subtitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          color: Theme.of(
                                            context,
                                          ).unselectedWidgetColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Divider(
                                      color: Theme.of(context).splashColor,
                                      thickness: 0.5,
                                    ),
                                    SizedBox(height: 15),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Yemək kartının istifadə qaydası",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Theme.of(context).splashColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    _buildExpansionTileCard(
                                      context: context,
                                      title:
                                          "Yemək kartının aktivasiya şərtləri",
                                      content:
                                          "Yemək kartının aktivasiya şərtləri",
                                    ),
                                    _buildExpansionTileCard(
                                      context: context,
                                      title:
                                          "Yemək kartının aktivasiya şərtləri",
                                      content:
                                          "Yemək kartının aktivasiya şərtləri",
                                    ),
                                    _buildExpansionTileCard(
                                      context: context,
                                      title:
                                          "Yemək kartının aktivasiya şərtləri",
                                      content:
                                          "Yemək kartının aktivasiya şərtləri",
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        AppTheme.adaptiveCheckbox(
                                          value: isRulesAccepted,
                                          onChanged: (value) {
                                            setState(() {
                                              isRulesAccepted = value ?? false;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Qaydaları oxudum və qəbul etdim",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onBackground,
                                            fontWeight: FontWeight.w400,
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
                      ],
                    ),
                  ),
                  bottomNavigationBar: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: isSecondPage
                            ? (isRulesAccepted
                                ? () {
                                    onChanged(true);
                                    Get.back();
                                  }
                                : null)
                            : (isTermsAccepted
                                ? () {
                                    _pageController.animateToPage(
                                      1,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null),
                        style: AppTheme.primaryButtonStyle(
                          isDisabled: isSecondPage
                              ? !isRulesAccepted
                              : !isTermsAccepted,
                        ),
                        child: Text(
                          isSecondPage ? 'activate'.tr : 'next'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'cancel'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).unselectedWidgetColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpansionTileCard({
    required String title,
    required String content,
    required BuildContext context,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.itemHover,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          iconColor: Theme.of(context).colorScheme.onBackground,
          collapsedIconColor: Theme.of(context).colorScheme.onBackground,
          childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          expandedAlignment: Alignment.centerLeft,
          children: [
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).unselectedWidgetColor,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
