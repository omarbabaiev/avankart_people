import '../utils/app_theme.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

class CountryPickerItem extends StatelessWidget {
  final String code;
  final String flag;
  final Country selectedCountry;
  final Function(Country) onCountrySelected;

  const CountryPickerItem({
    super.key,
    required this.code,
    required this.flag,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Ülkeyi oluşturup fonksiyonlarda kullanmak için
    final country = Country(
      phoneCode: code.replaceAll('+', ''),
      countryCode:
          flag.codeUnits.map((e) => String.fromCharCode(e - 127397)).join(),
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: flag,
      example: "501234567",
      displayName: "$flag ($code)",
      displayNameNoCountryCode: flag,
      e164Key: "",
    );

    return InkWell(
      onTap: () {
        onCountrySelected(country);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 24)),
            SizedBox(width: 14),
            Text(
              code,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTextColor,
              ),
            ),
            Spacer(),
            if (selectedCountry.phoneCode == code.replaceAll('+', ''))
              Icon(Icons.check, color: AppTheme.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
