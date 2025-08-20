import '../../utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import 'dart:async';
import '../../controllers/otp_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final OtpController controller = Get.put(OtpController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _textControllers =
      List.generate(6, (index) => TextEditingController());
  Timer? _timer;
  int _remainingTime = 299; // 4:59 dakika

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Controller'ın onInit fonksiyonu zaten email ve token'ı alıyor

    // Focus listener'ları ekle (border rengini güncellemek için)
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        setState(() {}); // Border rengini güncellemek için
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _textControllers) {
      controller.dispose();
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
    // Eğer bir karakter girildi ve son field değilse, sonrakine geç
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    // Eğer karakter silindi ve ilk field değilse, öncekine geç
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Tüm field'lardan OTP kodunu oluştur
    _updateOtpFromFields();
  }

  void _updateOtpFromFields() {
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += _textControllers[i].text;
    }
    controller.otpController.text = otp;
  }

  void _fillAllFields(String code) {
    // 6 haneli kodu tüm field'lara dağıt
    for (int i = 0; i < 6 && i < code.length; i++) {
      _textControllers[i].text = code[i];
    }
    // Son field'a focus ver
    if (code.length == 6) {
      _focusNodes[5].requestFocus();
    }
    _updateOtpFromFields();
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 45,
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _focusNodes[index].hasFocus
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).shadowColor,
            width: _focusNodes[index].hasFocus ? 2 : 1,
          ),
        ),
      ),
      child: TextField(
        style: TextStyle(
          fontFamily: "Poppins",
          color: Theme.of(context).colorScheme.onBackground,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        controller: _textControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          // Paste durumu kontrolü (6 haneli kod yapıştırıldıysa)
          if (value.length == 6 && index == 0) {
            _fillAllFields(value);
            return;
          }

          // Sadece son karakteri al (paste durumu için)
          if (value.length > 1) {
            value = value.substring(value.length - 1);
            _textControllers[index].text = value;
            _textControllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: value.length),
            );
          }

          _onCodeChanged(value, index);
        },
        onTap: () {
          // Android'de cursor position fix
          _textControllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _textControllers[index].text.length),
          );
        },
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          counter: const SizedBox.shrink(),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  bool _isCodeComplete() {
    String fullCode = '';
    for (int i = 0; i < 6; i++) {
      fullCode += _textControllers[i].text;
    }
    return fullCode.length == 6;
  }

  void _verifyCode() {
    // Tüm field'lardan kodu oluştur
    _updateOtpFromFields();

    // Kod tamamlanmış mı kontrol et
    if (controller.otpController.text.length == 6) {
      controller.submitOtp();
    } else {
      SnackbarUtils.showErrorSnackbar(
          'Lütfen 6 haneli kodu tam olarak daxil edin');
    }
  }

  void _resendCode() async {
    // Controller'ın resend metodunu çağır
    await controller.resendOtp();

    // Başarılı olursa timer'ı yeniden başlat ve field'ları temizle
    _clearAllFields();
    setState(() {
      _remainingTime = 299;
    });
    _startTimer();
  }

  void _clearAllFields() {
    for (int i = 0; i < 6; i++) {
      _textControllers[i].clear();
    }
    controller.otpController.clear();
    // İlk field'a focus ver
    _focusNodes[0].requestFocus();
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'otp'.tr,
              style: TextStyle(
                fontFamily: "Poppins",
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
                    text: controller.email.isNotEmpty ? controller.email : '',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: 'enter_verification_code'.tr,
                    style: TextStyle(
                      fontFamily: "Poppins",
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
              child: Obx(() => TextButton(
                    style:
                        TextButton.styleFrom(minimumSize: Size.fromHeight(40)),
                    onPressed:
                        (_remainingTime == 0 && !controller.isResending.value)
                            ? _resendCode
                            : null,
                    child: controller.isResending.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : Text(
                            'resend'.tr,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _remainingTime == 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[400],
                            ),
                          ),
                  )),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildOtpField(index)),
            ),
            const SizedBox(height: 40),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : (_isCodeComplete() ? _verifyCode : null),
                    style: AppTheme.primaryButtonStyle(),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text('verify'.tr, style: AppTheme.buttonTextStyle),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
