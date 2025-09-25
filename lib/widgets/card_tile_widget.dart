import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:avankart_people/models/card_models.dart';
import 'package:avankart_people/controllers/card_manage_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_svg_image/cached_network_svg_image.dart';

class CardTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final String status;
  final bool value;
  final bool isActive;
  final List<CardCondition> conditions;
  final String cardId;
  final ValueChanged<bool> onChanged;

  const CardTileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.status,
    required this.value,
    this.isActive = false,
    this.conditions = const <CardCondition>[],
    required this.cardId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive
          ? () => _cardDeactivateDetailBottomSheet(
                context,
                title,
                subtitle,
                icon,
                color.toString(),
              ) // Kart aktifse, deaktif sebeplerini sor
          : () => _cardActiveDetailBottomSheet(
                // Kart aktif değilse bottom sheet aç
                context,
                title,
                subtitle,
                icon,
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
              padding: EdgeInsets.all(6),
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkSVGImage(
                  'https://api.avankart.com/v1/icon/$icon',
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  placeholder: Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  errorWidget: Icon(
                    Icons.credit_card,
                    color: Colors.black,
                    size: 20,
                  ),
                  color: Colors.black,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
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
                    'cancelled' => Align(
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
              value: isActive,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (newValue) async {
                if (newValue) {
                  // Aktif etmek için bottom sheet göster
                  _cardActiveDetailBottomSheet(
                    context,
                    title,
                    subtitle,
                    icon,
                    color.toString(),
                  );
                } else {
                  // Deaktif etmek için bottom sheet göster
                  _cardDeactivateDetailBottomSheet(
                    context,
                    title,
                    subtitle,
                    icon,
                    color.toString(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showActivationConfirmationBottomSheet(
    BuildContext context,
    String title,
    String subtitle,
    String icon,
    String color,
  ) {
    context.showPerformantBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

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
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'activate_card'.tr,
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
                      '$title ${'activate_card_confirmation'.tr}',
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
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                              });

                              try {
                                // API çağrısı yap
                                final cardController =
                                    Get.find<CardManageController>();
                                final success = await cardController
                                    .requestChangeCardStatus(
                                  cardId: cardId,
                                  status: 'active',
                                  reasonIds: [], // Aktivasyon için boş array
                                );

                                if (success) {
                                  Get.back();
                                  SnackbarUtils.showSuccessSnackbar(
                                    'card_activation_request_sent'.tr,
                                  );
                                } else {
                                  Get.back();
                                  SnackbarUtils.showErrorSnackbar(
                                    'card_activation_request_failed'.tr,
                                  );
                                }
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                      style: AppTheme.primaryButtonStyle(
                        backgroundColor: AppTheme.primaryColor,
                        isDisabled: isLoading,
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'yes_activate'.tr,
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
                    onPressed: isLoading ? null : () => Get.back(),
                    child: Text(
                      'no'.tr,
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
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: this.color,
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkSVGImage(
                                          'https://api.avankart.com/v1/icon/$icon',
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.contain,
                                          placeholder: Icon(
                                            Icons.image_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground
                                                .withOpacity(0.5),
                                            size: 24,
                                          ),
                                          errorWidget: Icon(
                                            Icons.credit_card,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            size: 24,
                                          ),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          colorBlendMode: BlendMode.srcIn,
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
                                        "card_activation_conditions".tr,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Theme.of(context).splashColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    // Show activation conditions from API (filter by status = 'activate')
                                    if (conditions.isNotEmpty) ...[
                                      ...conditions.where((condition) {
                                        return condition.status == 'activate';
                                      }).map((condition) {
                                        return _buildExpansionTileCard(
                                          context: context,
                                          title: condition.title,
                                          content: condition.description,
                                        );
                                      }),
                                    ] else ...[
                                      _buildExpansionTileCard(
                                        context: context,
                                        title: "card_activation_conditions".tr,
                                        content: "no_activation_conditions".tr,
                                      ),
                                    ],
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
                                          "accept_terms".tr,
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
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: this.color,
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkSVGImage(
                                          'https://api.avankart.com/v1/icon/$icon',
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.contain,
                                          placeholder: Icon(
                                            Icons.image_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground
                                                .withOpacity(0.5),
                                            size: 24,
                                          ),
                                          errorWidget: Icon(
                                            Icons.credit_card,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            size: 24,
                                          ),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          colorBlendMode: BlendMode.srcIn,
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
                                        "card_usage_rules".tr,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Theme.of(context).splashColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    // Show usage conditions from API (filter by status = 'usage')
                                    if (conditions.isNotEmpty) ...[
                                      ...conditions.where((condition) {
                                        return condition.status == 'usage';
                                      }).map((condition) {
                                        return _buildExpansionTileCard(
                                          context: context,
                                          title: condition.title,
                                          content: condition.description,
                                        );
                                      }),
                                    ] else ...[
                                      _buildExpansionTileCard(
                                        context: context,
                                        title: "card_usage_rules".tr,
                                        content: "no_usage_rules".tr,
                                      ),
                                    ],
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
                                          "accept_rules".tr,
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
                                      // Önce onay bottom sheet'i göster
                                      Get.back(); // Mevcut bottom sheet'i kapat
                                      _showActivationConfirmationBottomSheet(
                                        context,
                                        title,
                                        subtitle,
                                        icon,
                                        color.toString(),
                                      );
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
                            isSecondPage ? 'activate_card'.tr : 'forward'.tr,
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
    // Deaktive sebepleri için map - API'den gelen deactivate condition'ları kullan
    Map<String, Map<String, dynamic>> deactivateReasons = {};

    // API'den gelen deactivate condition'larını map'e ekle
    for (var condition in conditions) {
      if (condition.status == 'deactivate') {
        deactivateReasons[condition.title] = {
          'selected': false,
          'subtitle': condition.description,
          'id': condition.id,
        };
      }
    }

    // Eğer API'den deactivate condition'ları gelmemişse, boş liste ile devam et
    // Bottom sheet her halda gösterilecek

    // En az bir sebep seçili mi veya səbəb yoxdursa
    bool isAnyReasonSelected =
        deactivateReasons.isEmpty; // Səbəb yoxdursa direkt aktif

    // Seçili sebep sayısını kontrol et
    void checkSelectedReasons() {
      isAnyReasonSelected = deactivateReasons.isEmpty || // Səbəb yoxdursa aktif
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
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: this.color,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: CachedNetworkSVGImage(
                                      'https://api.avankart.com/v1/icon/$icon',
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                      placeholder: Icon(
                                        Icons.image_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground
                                            .withOpacity(0.5),
                                        size: 24,
                                      ),
                                      errorWidget: Icon(
                                        Icons.credit_card,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        size: 24,
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      colorBlendMode: BlendMode.srcIn,
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
                                    "select_deactivation_reasons".tr,
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
                                if (deactivateReasons.isNotEmpty) ...[
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
                                  }),
                                ] else ...[
                                  // Səbəb yoxdursa mesaj göster
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).hoverColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).splashColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Theme.of(context)
                                              .unselectedWidgetColor,
                                          size: 20,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "no_reasons_available".tr,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .unselectedWidgetColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                              ? () async {
                                  setState(() {
                                    isAnyReasonSelected =
                                        false; // Loading state için
                                  });

                                  try {
                                    // Seçili deaktivasiya səbəblərinin ID'lerini topla
                                    final selectedReasonIds = <String>[];
                                    for (var entry
                                        in deactivateReasons.entries) {
                                      if (entry.value['selected'] == true) {
                                        selectedReasonIds
                                            .add(entry.value['id']);
                                      }
                                    }

                                    // API çağrısı yap
                                    final cardController =
                                        Get.find<CardManageController>();
                                    final success = await cardController
                                        .requestChangeCardStatus(
                                      cardId: cardId,
                                      status: 'deactive',
                                      reasonIds: selectedReasonIds,
                                    );

                                    if (success) {
                                      Get.back();
                                      SnackbarUtils.showSuccessSnackbar(
                                        'card_deactivation_request_sent'.tr,
                                      );
                                    } else {
                                      Get.back();
                                      SnackbarUtils.showErrorSnackbar(
                                        'card_deactivation_request_failed'.tr,
                                      );
                                    }
                                  } finally {
                                    setState(() {
                                      isAnyReasonSelected = deactivateReasons
                                              .isEmpty ||
                                          deactivateReasons.values.any(
                                              (value) =>
                                                  value['selected'] == true);
                                    });
                                  }
                                }
                              : null,
                          style: AppTheme.primaryButtonStyle(
                            isDisabled: !isAnyReasonSelected,
                          ),
                          child: !isAnyReasonSelected
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'confirm'.tr,
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
