import 'package:avankart_people/routes/app_routes.dart';

import 'login_screen.dart';
import '../../../utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_theme.dart';
import 'dart:async';
import 'new_password_screen.dart';

class EmailVerificationForNewUserScreen extends StatefulWidget {
  final String email;

  const EmailVerificationForNewUserScreen({super.key, required this.email});

  @override
  State<EmailVerificationForNewUserScreen> createState() =>
      _EmailVerificationForNewUserScreenState();
}

class _EmailVerificationForNewUserScreenState
    extends State<EmailVerificationForNewUserScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  Timer? _timer;
  int _remainingTime = 299; // 4:59 dakika

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '$minutes : ${seconds.toString().padLeft(2, '0')}';
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_isCodeComplete()) {
      // _verifyCode();
    }
  }

  bool _isCodeComplete() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  void _verifyCode() {
    String code = _controllers.map((c) => c.text).join();
    // TODO: Implement verification logic
    SnackbarUtils.showSnackbar('verification_successful'.tr);

    Get.offAllNamed(AppRoutes.cards);
  }

  void _resendCode() {
    // TODO: Implement resend logic
    setState(() {
      _remainingTime = 299;
    });
    _startTimer();
    SnackbarUtils.showSnackbar('code_resent'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'otp'.tr,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 23,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.email,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: 'enter_verification_code'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                width: 60,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  _formattedTime,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: Size.fromHeight(40)),
                onPressed: _remainingTime == 0 ? _resendCode : null,
                child: Text(
                  'resend'.tr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _remainingTime == 0
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 45,
                  child: TextField(
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counter: Text(""),
                      hintStyle: TextStyle(
                        color: Theme.of(context).shadowColor,
                        fontSize: 14,
                      ),
                      filled: false,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      errorStyle: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).shadowColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1,
                        ),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 1,
                        ),
                      ),
                    ),
                    onChanged: (value) => _onCodeChanged(value, index),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isCodeComplete() ? _verifyCode : () {},
              style: AppTheme.primaryButtonStyle(),
              child: Text('next'.tr, style: AppTheme.buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}
