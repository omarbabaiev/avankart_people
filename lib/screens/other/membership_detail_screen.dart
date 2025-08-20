import 'dart:async';

import 'package:avankart_people/controllers/membership_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/widgets/restaurant_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MembershipDetailScreen extends GetView<MembershipController> {
  final Map<String, dynamic> membership = Get.arguments as Map<String, dynamic>;

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  Timer? _timer;
  final _remainingTimeNotifier = ValueNotifier<int>(299);

  @override
  void dispose() {
    _timer?.cancel();
    _remainingTimeNotifier.dispose();

    // OTP controller ve focus node'ları temizle
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
  }

  String get _formattedTime {
    int minutes = _remainingTimeNotifier.value ~/ 60;
    int seconds = _remainingTimeNotifier.value % 60;
    return '$minutes : ${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingTimeNotifier.value = 299;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeNotifier.value > 0) {
        _remainingTimeNotifier.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Seçilen üyeliği controller'a bildir
    controller.setSelectedMembership(membership);

    // Kategorileri spending değerine göre çoktan aza sırala
    List<dynamic> sortedCategories =
        List<dynamic>.from(membership['categories'] ?? [])
          ..sort((a, b) =>
              (b['spending'] as double).compareTo(a['spending'] as double));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            membership['name'],
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: Theme.of(context).colorScheme.onPrimary,
            margin: EdgeInsets.symmetric(vertical: 4),
            padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 25),
            child: Column(
              children: [
                Text("Toplam xərcləmə",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).unselectedWidgetColor)),
                SizedBox(height: 5),
                Text("₼ ${membership['totalSpending']}",
                    style: TextStyle(
    fontFamily: 'Inter',
                        fontSize: 26, fontWeight: FontWeight.w700)),
                SizedBox(height: 5),
                Text("${membership["startDate"]} > Bu gün",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).unselectedWidgetColor)),
                SizedBox(height: 12),

                // Sıralanmış kategorileri ListView.builder ile oluştur
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: sortedCategories.length,
                  itemBuilder: (context, index) {
                    final category = sortedCategories[index];
                    return _buildMembershipDetailTile(
                      context,
                      category['name'],
                      Color(category['colorHex']),
                      membership['totalSpending'],
                      category['spending'],
                      category['iconPath'],
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          membership['isEnd']
              ? Container()
              : CupertinoButton(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  onPressed: () {
                    _showMembershipLeaveDialog(context);
                  },
                  child: Text("Üzvlükdən ayrıl",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.error)),
                )
        ],
      ),
    );
  }

  Container _buildMembershipDetailTile(
      BuildContext context,
      String title,
      Color color,
      double totalSpending,
      double currentSpending,
      String iconLink) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color,
                    child: Image.asset(iconLink, width: 22, height: 22),
                  ),
                  SizedBox(width: 8),
                  Text(title,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onBackground)),
                ],
              ),
              Text("${currentSpending.toString()} ₼",
                  style: TextStyle(
    fontFamily: 'Roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onBackground)),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 11,
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(24),
                  value: currentSpending / totalSpending,
                  minHeight: 6,
                  color: color,
                  backgroundColor:
                      Theme.of(context).unselectedWidgetColor.withOpacity(0.2),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Text(
                    "${(currentSpending / totalSpending * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
    fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).unselectedWidgetColor)),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showVerificationBottomSheet(BuildContext context) {
    _startTimer();
    context.showPerformantBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  context.buildBottomSheetHandle(),
                  const SizedBox(height: 10),
                  Text(
                    'otp'.tr,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "omarbaba007@gmail.com",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      children: [
                        TextSpan(
                          text: " ",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        TextSpan(
                          text:
                              "enter_verification_code".tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _remainingTimeNotifier,
                      builder: (context, value, child) {
                        return Text(
                          _formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      _startTimer();
                      // TODO: Implement resend logic
                    },
                    child: Text(
                      'resend'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                      (index) => SizedBox(
                        width: 50,
                        child: TextFormField(
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (index < 5) {
                                _otpFocusNodes[index + 1].requestFocus();
                              } else {
                                _otpFocusNodes[index].unfocus();
                              }
                            }
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.transparent,
                            counterText: '',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _timer?.cancel();
                        Get.back();
                        // _showSuccessScreen();
                      },
                      style: AppTheme.primaryButtonStyle(),
                      child: Text(
                        'Təsdiqlə',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      _timer?.cancel();
                      Get.back();
                    },
                    child: Text(
                      'Ləğv et',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Theme.of(context).unselectedWidgetColor,
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

  void _showMembershipLeaveDialog(BuildContext context) {
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onError,
                  shape: BoxShape.circle,
                ),
                child: Transform.rotate(
                  angle: 3.14,
                  child: Icon(
                    Icons.logout_outlined,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Üzvlükdən ayrıl',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Üzvlükdən ayrılmaq istədiyinizə əminsiniz ?',
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
                    Get.back();
                    _showVerificationBottomSheet(context);
                  },
                  style: AppTheme.primaryButtonStyle(
                    backgroundColor: AppTheme.error,
                  ),
                  child: Text(
                    'Bəli, ayrıl',
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
  }
}
