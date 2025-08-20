import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/get_rx.dart';

class CardTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String status;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CardTileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.status,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: value
          ? () => _cardDeactivateDetailBottomSheet(
                context,
                title,
                subtitle,
                icon.toString(),
                color.toString(),
              ) // Kart aktifse, deaktif sebeplerini sor
          : () => _cardActiveDetailBottomSheet(
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
                  SizedBox(height: 4),
                  switch (status) {
                    'waiting' => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "waiting_confirmation".tr,
                          style: TextStyle(
    fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffF9B100),
                          ),
                        ),
                      ),
                    'canceled' => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "rejected".tr,
                          style: TextStyle(
    fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    _ => SizedBox(),
                  },
                ],
              ),
            ),
            SizedBox(width: 16),
            Switch.adaptive(
              value: value,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: value
                  ? (newValue) {
                      // Sadece aktiften inaktife geçişe izin ver ve sebep dialogu göster
                      if (!newValue) {
                        _cardDeactivateDetailBottomSheet(
                          context,
                          title,
                          subtitle,
                          icon.toString(),
                          color.toString(),
                        );
                      }
                    }
                  : null, // Değer false ise değiştirilemez
            ),
          ],
        ),
      ),
    );
  }

  void _showDeactivateSheet(BuildContext context) {
    context.showPerformantBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).hoverColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.power_settings_new,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Kartı deaktiv et',
                style: TextStyle(
    fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Kartı deaktiv etmək istədiyinizə əminsiniz?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  onPressed: () {
                    onChanged(false); // Kartı deaktif et
                    Get.back();
                  },
                  style: AppTheme.primaryButtonStyle(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(
                    'Bəli, deaktiv et',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Xeyr',
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
        );
      },
    );
  }

  void _cardActiveDetailBottomSheet(
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
                                        horizontal: 24,
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
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
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
                            isSecondPage ? 'Aktivləşdir' : 'İrəli',
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
                            'Ləğv et',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).unselectedWidgetColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _cardDeactivateDetailBottomSheet(
    BuildContext context,
    String title,
    String subtitle,
    String icon,
    String color,
  ) {
    // Deaktive sebepleri için map - key: sebep, value: [seçili mi, alt açıklama]
    Map<String, Map<String, dynamic>> deactivateReasons = {
      "Şirkətdən istifadə etmək istəmirəm": {
        'selected': false,
        'subtitle':
            "Başqa bir şirkət tərəfindən təqdim olunan üstünlük istifadə etmək istəyirəm"
      },
      "Kartın müddəti bitib": {
        'selected': false,
        'subtitle': "Kartın etibarlılıq müddəti bitib və yeniləmək istəmirəm"
      },
      "Müəssisə istifadəyə uyğun deyil": {
        'selected': false,
        'subtitle': "Mənim ehtiyaclarıma uyğun restoran və ya xidmətlər yoxdur"
      },
    };

    // En az bir sebep seçili mi
    bool isAnyReasonSelected = false;

    // Seçili sebep sayısını kontrol et
    void checkSelectedReasons() {
      isAnyReasonSelected =
          deactivateReasons.values.any((value) => value['selected'] == true);
    }

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
                          child: SingleChildScrollView(
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
                                    "Kartı hansı səbəblərdən deaktiv etmək istədiyinizi seçin",
                                    style: TextStyle(
    fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Theme.of(context).splashColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),

                                // Sebep seçim listesi
                                ...deactivateReasons.keys.map((reason) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: Theme(
                                          data: Theme.of(context),
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: AppTheme.adaptiveCheckbox(
                                              value: deactivateReasons[reason]
                                                      ?['selected'] ??
                                                  false,
                                              onChanged: (value) {
                                                setState(() {
                                                  deactivateReasons[reason]
                                                          ?['selected'] =
                                                      value ?? false;
                                                  checkSelectedReasons();
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          reason,
                                          style: TextStyle(
    fontFamily: 'Poppins',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                        ),
                                        subtitle: Text(
                                          deactivateReasons[reason]
                                                  ?['subtitle'] ??
                                              '',
                                          style: TextStyle(
    fontFamily: 'Poppins',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: Theme.of(context)
                                                  .unselectedWidgetColor),
                                        ),
                                      ),
                                      Divider(
                                        color: Theme.of(context).splashColor,
                                        thickness: 0.2,
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: isAnyReasonSelected
                              ? () {
                                  Get.back();
                                  _showDeactivateSheet(context);
                                }
                              : null,
                          style: AppTheme.primaryButtonStyle(
                            isDisabled: !isAnyReasonSelected,
                          ),
                          child: Text(
                            'Təsdiqlə',
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
                            'Ləğv et',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).unselectedWidgetColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
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
