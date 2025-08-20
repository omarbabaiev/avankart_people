import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../utils/bottom_sheet_extension.dart';

class CountryPickerBottomSheet {
  static void show(BuildContext context, Country selectedCountry,
      Function(Country) onCountryChanged) {
    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: 50,
                  itemBuilder: (BuildContext context, int index) {
                    return [
                      _buildCountryItem(context, '+994', '🇦🇿',
                          selectedCountry, onCountryChanged), // Azerbaijan
                      _buildCountryItem(context, '+90', '🇹🇷', selectedCountry,
                          onCountryChanged), // Turkey
                      _buildCountryItem(context, '+7', '🇷🇺', selectedCountry,
                          onCountryChanged), // Russia
                      _buildCountryItem(context, '+380', '🇺🇦',
                          selectedCountry, onCountryChanged), // Ukraine
                      _buildCountryItem(context, '+44', '🇬🇧', selectedCountry,
                          onCountryChanged), // United Kingdom
                      _buildCountryItem(context, '+1', '🇺🇸', selectedCountry,
                          onCountryChanged), // United States
                      _buildCountryItem(context, '+49', '🇩🇪', selectedCountry,
                          onCountryChanged), // Germany
                      _buildCountryItem(context, '+33', '🇫🇷', selectedCountry,
                          onCountryChanged), // France
                      _buildCountryItem(context, '+39', '🇮🇹', selectedCountry,
                          onCountryChanged), // Italy
                      _buildCountryItem(context, '+34', '🇪🇸', selectedCountry,
                          onCountryChanged), // Spain
                      _buildCountryItem(context, '+86', '🇨🇳', selectedCountry,
                          onCountryChanged), // China
                      _buildCountryItem(context, '+81', '🇯🇵', selectedCountry,
                          onCountryChanged), // Japan
                      _buildCountryItem(context, '+82', '🇰🇷', selectedCountry,
                          onCountryChanged), // South Korea
                      _buildCountryItem(context, '+91', '🇮🇳', selectedCountry,
                          onCountryChanged), // India
                      _buildCountryItem(context, '+62', '🇮🇩', selectedCountry,
                          onCountryChanged), // Indonesia
                      _buildCountryItem(context, '+60', '🇲🇾', selectedCountry,
                          onCountryChanged), // Malaysia
                      _buildCountryItem(context, '+65', '🇸🇬', selectedCountry,
                          onCountryChanged), // Singapore
                      _buildCountryItem(context, '+66', '🇹🇭', selectedCountry,
                          onCountryChanged), // Thailand
                      _buildCountryItem(context, '+84', '🇻🇳', selectedCountry,
                          onCountryChanged), // Vietnam
                      _buildCountryItem(context, '+61', '🇦🇺', selectedCountry,
                          onCountryChanged), // Australia
                      _buildCountryItem(context, '+64', '🇳🇿', selectedCountry,
                          onCountryChanged), // New Zealand
                      _buildCountryItem(context, '+27', '🇿🇦', selectedCountry,
                          onCountryChanged), // South Africa
                      _buildCountryItem(context, '+20', '🇪🇬', selectedCountry,
                          onCountryChanged), // Egypt
                      _buildCountryItem(context, '+212', '🇲🇦',
                          selectedCountry, onCountryChanged), // Morocco
                      _buildCountryItem(context, '+234', '🇳🇬',
                          selectedCountry, onCountryChanged), // Nigeria
                      _buildCountryItem(context, '+55', '🇧🇷', selectedCountry,
                          onCountryChanged), // Brazil
                      _buildCountryItem(context, '+54', '🇦🇷', selectedCountry,
                          onCountryChanged), // Argentina
                      _buildCountryItem(context, '+56', '🇨🇱', selectedCountry,
                          onCountryChanged), // Chile
                      _buildCountryItem(context, '+57', '🇨🇴', selectedCountry,
                          onCountryChanged), // Colombia
                      _buildCountryItem(context, '+52', '🇲🇽', selectedCountry,
                          onCountryChanged), // Mexico
                      _buildCountryItem(context, '+31', '🇳🇱', selectedCountry,
                          onCountryChanged), // Netherlands
                      _buildCountryItem(context, '+32', '🇧🇪', selectedCountry,
                          onCountryChanged), // Belgium
                      _buildCountryItem(context, '+41', '🇨🇭', selectedCountry,
                          onCountryChanged), // Switzerland
                      _buildCountryItem(context, '+43', '🇦🇹', selectedCountry,
                          onCountryChanged), // Austria
                      _buildCountryItem(context, '+46', '🇸🇪', selectedCountry,
                          onCountryChanged), // Sweden
                      _buildCountryItem(context, '+47', '🇳🇴', selectedCountry,
                          onCountryChanged), // Norway
                      _buildCountryItem(context, '+45', '🇩🇰', selectedCountry,
                          onCountryChanged), // Denmark
                      _buildCountryItem(context, '+358', '🇫🇮',
                          selectedCountry, onCountryChanged), // Finland
                      _buildCountryItem(context, '+48', '🇵🇱', selectedCountry,
                          onCountryChanged), // Poland
                      _buildCountryItem(context, '+420', '🇨🇿',
                          selectedCountry, onCountryChanged), // Czech Republic
                      _buildCountryItem(context, '+36', '🇭🇺', selectedCountry,
                          onCountryChanged), // Hungary
                      _buildCountryItem(context, '+30', '🇬🇷', selectedCountry,
                          onCountryChanged), // Greece
                      _buildCountryItem(context, '+40', '🇷🇴', selectedCountry,
                          onCountryChanged), // Romania
                      _buildCountryItem(context, '+359', '🇧🇬',
                          selectedCountry, onCountryChanged), // Bulgaria
                      _buildCountryItem(context, '+351', '🇵🇹',
                          selectedCountry, onCountryChanged), // Portugal
                      _buildCountryItem(context, '+353', '🇮🇪',
                          selectedCountry, onCountryChanged), // Ireland
                      _buildCountryItem(context, '+972', '🇮🇱',
                          selectedCountry, onCountryChanged), // Israel
                      _buildCountryItem(context, '+971', '🇦🇪',
                          selectedCountry, onCountryChanged), // UAE
                      _buildCountryItem(context, '+966', '🇸🇦',
                          selectedCountry, onCountryChanged), // Saudi Arabia
                      _buildCountryItem(context, '+974', '🇶🇦',
                          selectedCountry, onCountryChanged), // Qatar
                      _buildCountryItem(context, '+965', '🇰🇼',
                          selectedCountry, onCountryChanged), // Kuwait
                    ][index];
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      indent: 25,
                      endIndent: 25,
                      height: .1,
                      color: Theme.of(context).dividerColor,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildCountryItem(
      BuildContext context,
      String code,
      String flag,
      Country selectedCountry,
      Function(Country) onCountryChanged) {
    bool isSelected = code == '+${selectedCountry.phoneCode}';

    return InkWell(
      onTap: () {
        onCountryChanged(Country(
          phoneCode: code.substring(1),
          countryCode: "",
          e164Sc: 0,
          geographic: true,
          level: 1,
          name: "",
          example: "",
          displayName: "[+$code]",
          displayNameNoCountryCode: "",
          e164Key: "",
        ));
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        color: Colors.transparent,
        child: Row(
          children: [
            Radio(
              value: code,
              groupValue: '+${selectedCountry.phoneCode}',
              onChanged: (value) {
                onCountryChanged(Country(
                  phoneCode: code.substring(1),
                  countryCode: "",
                  e164Sc: 0,
                  geographic: true,
                  level: 1,
                  name: "",
                  example: "",
                  displayName: "[+$code]",
                  displayNameNoCountryCode: "",
                  e164Key: "",
                ));
                Navigator.pop(context);
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            Text(
              code,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(flag, style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
