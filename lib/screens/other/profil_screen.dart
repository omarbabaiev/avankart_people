import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/screens/security/pin_code_screen.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/utils/masked_text_formatter.dart';
import 'package:avankart_people/widgets/restaurant_card_widget.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilScreen extends StatefulWidget {
  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Profil',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            _profileTile(
                context, 'Ad və Soyad', 'Ramin Orucov', ImageAssets.pencil, () {
              _showNameChangeAlert();
            }),
            _profileTile(
                context, 'Doğum tarixi', '16.12.1999', ImageAssets.pencil, () {
              _showBirthDateChangeAlert();
            }),
            _profileTile(
                context, 'Telefon nömrəsi', '+994517777777', ImageAssets.pencil,
                () {
              _showPhoneChangeAlert(context);
            }),
            _profileTile(context, 'Cinsi', 'Kişi', ImageAssets.pencil, () {}),
            _profileTile(context, 'İstifadəçi ID', 'AP-XXXXXXXXXX',
                ImageAssets.copySimple, () {}),
            _profileTile(context, 'Üzv olduğu şirkət', 'Veysəloğlu MMC',
                ImageAssets.copySimple, () {}),
          ],
        ),
      ),
    );
  }

  ListTile _profileTile(
    BuildContext context,
    String title,
    String subtitle,
    String icon,
    void Function() onTap,
  ) {
    return ListTile(
      onTap: onTap,
      title: Text(title,
          style: GoogleFonts.poppins(
            color: Theme.of(context).unselectedWidgetColor,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          )),
      subtitle: Text(subtitle,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          )),
      trailing: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          icon,
          color: Theme.of(context).colorScheme.onBackground,
          height: 24,
          width: 24,
        ),
      ),
    );
  }

  void _showPhoneChangeAlert(BuildContext context) {
    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: Get.size.height * 0.35,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              Text(
                'phone_number_change'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  MaskedTextInputFormatter(
                    mask: 'xx xxx xx xx',
                    separator: ' ',
                  ),
                ],
                decoration: InputDecoration(
                  hintStyle: GoogleFonts.poppins(
                    color: Theme.of(context).hintColor,
                    fontSize: 15,
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  errorStyle: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).shadowColor, // Siyah renk %10 opaklık
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
                  hintText: 'XX XXX XX XX',
                  prefixIcon: InkWell(
                    onTap: _showCountryPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "+${_selectedCountry.phoneCode}",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Image.asset(
                            ImageAssets.careddown,
                            height: 20,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ],
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'phone_number_empty'.tr;
                  }
                  // Boşlukları kaldırıp doğru uzunlukta olup olmadığını kontrol et
                  String cleanedValue = value.replaceAll(' ', '');
                  if (cleanedValue.length < 9) {
                    return 'invalid_phone_number'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: AppTheme.primaryButtonStyle(),
                  child: Text(
                    'Dəyiş',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Ləğv et',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBirthDateChangeAlert() {
    DateTime selectedDate = DateTime.now();
    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: Get.height * 0.5,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              Text(
                'birth_date_change'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 100,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime(2004, 1, 1),
                    maximumDate: DateTime.now(),
                    minimumYear: 1900,
                    maximumYear: DateTime.now().year,
                    onDateTimeChanged: (DateTime newDate) {
                      selectedDate = newDate;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(result: selectedDate);
                  },
                  style: AppTheme.primaryButtonStyle(),
                  child: Text(
                    'Dəyiş',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Ləğv et',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNameChangeAlert() {
    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'full_name_change'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: InputDecoration(
                        fillColor: Colors.transparent,
                        hintText: 'Ad və soyadı daxil edin',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Theme.of(context).hintColor,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).shadowColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: AppTheme.primaryButtonStyle(),
                        child: Text(
                          'Dəyiş',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Ləğv et',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmailChangeAlert() {
    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              Text(
                'email_change'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(
                  fillColor: Colors.transparent,
                  hintText: 'Yeni e-poçt adresini daxil edin',
                  hintStyle: GoogleFonts.poppins(
                    color: Theme.of(context).hintColor,
                    fontSize: 15,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).shadowColor,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).shadowColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: AppTheme.primaryButtonStyle(),
                  child: Text(
                    'Dəyiş',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Ləğv et',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final _phoneController = TextEditingController();

  Country _selectedCountry = Country(
    phoneCode: "994",
    countryCode: "AZ",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Azerbaijan",
    example: "501234567",
    displayName: "Azerbaijan (AZ) [+994]",
    displayNameNoCountryCode: "Azerbaijan (AZ)",
    e164Key: "",
  );

  void _showCountryPicker() {
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
                      _buildCountryItem('+994', '🇦🇿', context), // Azerbaijan
                      _buildCountryItem('+90', '🇹🇷', context), // Turkey
                      _buildCountryItem('+7', '🇷🇺', context), // Russia
                      _buildCountryItem('+380', '🇺🇦', context), // Ukraine
                      _buildCountryItem(
                          '+44', '🇬🇧', context), // United Kingdom
                      _buildCountryItem('+1', '🇺🇸', context), // United States
                      _buildCountryItem('+49', '🇩🇪', context), // Germany
                      _buildCountryItem('+33', '🇫🇷', context), // France
                      _buildCountryItem('+39', '🇮🇹', context), // Italy
                      _buildCountryItem('+34', '🇪🇸', context), // Spain
                      _buildCountryItem('+86', '🇨🇳', context), // China
                      _buildCountryItem('+81', '🇯🇵', context), // Japan
                      _buildCountryItem('+82', '🇰🇷', context), // South Korea
                      _buildCountryItem('+91', '🇮🇳', context), // India
                      _buildCountryItem('+62', '🇮🇩', context), // Indonesia
                      _buildCountryItem('+60', '🇲🇾', context), // Malaysia
                      _buildCountryItem('+65', '🇸🇬', context), // Singapore
                      _buildCountryItem('+66', '🇹🇭', context), // Thailand
                      _buildCountryItem('+84', '🇻🇳', context), // Vietnam
                      _buildCountryItem('+61', '🇦🇺', context), // Australia
                      _buildCountryItem('+64', '🇳🇿', context), // New Zealand
                      _buildCountryItem('+27', '🇿🇦', context), // South Africa
                      _buildCountryItem('+20', '🇪🇬', context), // Egypt
                      _buildCountryItem('+212', '🇲🇦', context), // Morocco
                      _buildCountryItem('+234', '🇳🇬', context), // Nigeria
                      _buildCountryItem('+55', '🇧🇷', context), // Brazil
                      _buildCountryItem('+54', '🇦🇷', context), // Argentina
                      _buildCountryItem('+56', '🇨🇱', context), // Chile
                      _buildCountryItem('+57', '🇨🇴', context), // Colombia
                      _buildCountryItem('+52', '🇲🇽', context), // Mexico
                      _buildCountryItem('+31', '🇳🇱', context), // Netherlands
                      _buildCountryItem('+32', '🇧🇪', context), // Belgium
                      _buildCountryItem('+41', '🇨🇭', context), // Switzerland
                      _buildCountryItem('+43', '🇦🇹', context), // Austria
                      _buildCountryItem('+46', '🇸🇪', context), // Sweden
                      _buildCountryItem('+47', '🇳🇴', context), // Norway
                      _buildCountryItem('+45', '🇩🇰', context), // Denmark
                      _buildCountryItem('+358', '🇫🇮', context), // Finland
                      _buildCountryItem('+48', '🇵🇱', context), // Poland
                      _buildCountryItem(
                          '+420', '🇨🇿', context), // Czech Republic
                      _buildCountryItem('+36', '🇭🇺', context), // Hungary
                      _buildCountryItem('+30', '🇬🇷', context), // Greece
                      _buildCountryItem('+40', '🇷🇴', context), // Romania
                      _buildCountryItem('+359', '🇧🇬', context), // Bulgaria
                      _buildCountryItem('+351', '🇵🇹', context), // Portugal
                      _buildCountryItem('+353', '🇮🇪', context), // Ireland
                      _buildCountryItem('+972', '🇮🇱', context), // Israel
                      _buildCountryItem('+971', '🇦🇪', context), // UAE
                      _buildCountryItem(
                          '+966', '🇸🇦', context), // Saudi Arabia
                      _buildCountryItem('+974', '🇶🇦', context), // Qatar
                      _buildCountryItem('+965', '🇰🇼', context), // Kuwait
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

  Widget _buildCountryItem(String code, String flag, BuildContext context) {
    bool isSelected = code == '+${_selectedCountry.phoneCode}';

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCountry = Country(
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
          );
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        color: Colors.transparent,
        child: Row(
          children: [
            Radio(
              value: code,
              groupValue: '+${_selectedCountry.phoneCode}',
              onChanged: (value) {
                setState(() {
                  _selectedCountry = Country(
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
                  );
                });
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
