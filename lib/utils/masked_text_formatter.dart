import 'package:flutter/services.dart';

class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter({required this.mask, required this.separator});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    if (newValue.text.length > mask.length) {
      return oldValue;
    }

    // Sadece sayıların girilmesini sağla
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Maskeye göre biçimlendir
    String formatted = '';
    int maskIndex = 0;
    int numIndex = 0;

    while (maskIndex < mask.length && numIndex < newText.length) {
      if (mask[maskIndex] == 'x') {
        formatted += newText[numIndex];
        numIndex++;
      } else {
        formatted += mask[maskIndex];
      }
      maskIndex++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
