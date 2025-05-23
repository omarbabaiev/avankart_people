import '../../../routes/app_routes.dart';
import '../../assets/image_assets.dart';
import '../../../utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'email_verification_screen.dart';
import '../../../utils/masked_text_formatter.dart';
import '../../../utils/bottom_sheet_extension.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
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

  final List<String> _genders = ['male'.tr, 'female'.tr, 'other'.tr];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  void _showGenderBottomSheet() {
    context.showPerformantBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            context.buildBottomSheetHandle(),
            const SizedBox(height: 10),
            ListTile(
              leading: Radio<String>(
                activeColor: Theme.of(context).colorScheme.primary,
                value: 'male'.tr,
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                  this.setState(() {});
                  Navigator.pop(context);
                },
              ),
              title: Text(
                'male'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: _selectedGender == 'male'.tr
                      ? Theme.of(context).colorScheme.onBackground
                      : Theme.of(context).unselectedWidgetColor,
                ),
              ),
              onTap: () {
                setState(() => _selectedGender = 'male'.tr);
                this.setState(() {});
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Radio<String>(
                value: 'female'.tr,
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                  this.setState(() {});
                  Navigator.pop(context);
                },
                activeColor: AppTheme.primaryColor,
              ),
              title: Text(
                'female'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: _selectedGender == 'female'.tr
                      ? Theme.of(context).colorScheme.onBackground
                      : Theme.of(context).unselectedWidgetColor,
                ),
              ),
              onTap: () {
                setState(() => _selectedGender = 'female'.tr);
                this.setState(() {});
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

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
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: 50,
                  itemBuilder: (BuildContext context, int index) {
                    return [
                      _buildCountryItem('+994', '🇦🇿'), // Azerbaijan
                      _buildCountryItem('+90', '🇹🇷'), // Turkey
                      _buildCountryItem('+7', '🇷🇺'), // Russia
                      _buildCountryItem('+380', '🇺🇦'), // Ukraine
                      _buildCountryItem('+44', '🇬🇧'), // United Kingdom
                      _buildCountryItem('+1', '🇺🇸'), // United States
                      _buildCountryItem('+49', '🇩🇪'), // Germany
                      _buildCountryItem('+33', '🇫🇷'), // France
                      _buildCountryItem('+39', '🇮🇹'), // Italy
                      _buildCountryItem('+34', '🇪🇸'), // Spain
                      _buildCountryItem('+86', '🇨🇳'), // China
                      _buildCountryItem('+81', '🇯🇵'), // Japan
                      _buildCountryItem('+82', '🇰🇷'), // South Korea
                      _buildCountryItem('+91', '🇮🇳'), // India
                      _buildCountryItem('+62', '🇮🇩'), // Indonesia
                      _buildCountryItem('+60', '🇲🇾'), // Malaysia
                      _buildCountryItem('+65', '🇸🇬'), // Singapore
                      _buildCountryItem('+66', '🇹🇭'), // Thailand
                      _buildCountryItem('+84', '🇻🇳'), // Vietnam
                      _buildCountryItem('+61', '🇦🇺'), // Australia
                      _buildCountryItem('+64', '🇳🇿'), // New Zealand
                      _buildCountryItem('+27', '🇿🇦'), // South Africa
                      _buildCountryItem('+20', '🇪🇬'), // Egypt
                      _buildCountryItem('+212', '🇲🇦'), // Morocco
                      _buildCountryItem('+234', '🇳🇬'), // Nigeria
                      _buildCountryItem('+55', '🇧🇷'), // Brazil
                      _buildCountryItem('+54', '🇦🇷'), // Argentina
                      _buildCountryItem('+56', '🇨🇱'), // Chile
                      _buildCountryItem('+57', '🇨🇴'), // Colombia
                      _buildCountryItem('+52', '🇲🇽'), // Mexico
                      _buildCountryItem('+31', '🇳🇱'), // Netherlands
                      _buildCountryItem('+32', '🇧🇪'), // Belgium
                      _buildCountryItem('+41', '🇨🇭'), // Switzerland
                      _buildCountryItem('+43', '🇦🇹'), // Austria
                      _buildCountryItem('+46', '🇸🇪'), // Sweden
                      _buildCountryItem('+47', '🇳🇴'), // Norway
                      _buildCountryItem('+45', '🇩🇰'), // Denmark
                      _buildCountryItem('+358', '🇫🇮'), // Finland
                      _buildCountryItem('+48', '🇵🇱'), // Poland
                      _buildCountryItem('+420', '🇨🇿'), // Czech Republic
                      _buildCountryItem('+36', '🇭🇺'), // Hungary
                      _buildCountryItem('+30', '🇬🇷'), // Greece
                      _buildCountryItem('+40', '🇷🇴'), // Romania
                      _buildCountryItem('+359', '🇧🇬'), // Bulgaria
                      _buildCountryItem('+351', '🇵🇹'), // Portugal
                      _buildCountryItem('+353', '🇮🇪'), // Ireland
                      _buildCountryItem('+972', '🇮🇱'), // Israel
                      _buildCountryItem('+971', '🇦🇪'), // UAE
                      _buildCountryItem('+966', '🇸🇦'), // Saudi Arabia
                      _buildCountryItem('+974', '🇶🇦'), // Qatar
                      _buildCountryItem('+965', '🇰🇼'), // Kuwait
                    ][index];
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      indent: 25,
                      endIndent: 25,
                      height: .1,
                      color: AppTheme.hintAccent.withOpacity(.3),
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

  Widget _buildCountryItem(String code, String flag) {
    bool isSelected = code == '+${_selectedCountry.phoneCode}';
    String countryKey = '';

    switch (code) {
      case '+994':
        countryKey = 'azerbaijan';
        break;
      case '+90':
        countryKey = 'turkey';
        break;
      case '+7':
        countryKey = 'russia';
        break;
      case '+380':
        countryKey = 'ukraine';
        break;
      case '+44':
        countryKey = 'united_kingdom';
        break;
      case '+1':
        countryKey = 'united_states';
        break;
      case '+49':
        countryKey = 'germany';
        break;
      case '+33':
        countryKey = 'france';
        break;
      case '+39':
        countryKey = 'italy';
        break;
      case '+34':
        countryKey = 'spain';
        break;
      case '+86':
        countryKey = 'china';
        break;
      case '+81':
        countryKey = 'japan';
        break;
      case '+82':
        countryKey = 'south_korea';
        break;
      case '+91':
        countryKey = 'india';
        break;
      case '+62':
        countryKey = 'indonesia';
        break;
      case '+60':
        countryKey = 'malaysia';
        break;
      case '+65':
        countryKey = 'singapore';
        break;
      case '+66':
        countryKey = 'thailand';
        break;
      case '+84':
        countryKey = 'vietnam';
        break;
      case '+61':
        countryKey = 'australia';
        break;
      case '+64':
        countryKey = 'new_zealand';
        break;
      case '+27':
        countryKey = 'south_africa';
        break;
      case '+20':
        countryKey = 'egypt';
        break;
      case '+212':
        countryKey = 'morocco';
        break;
      case '+234':
        countryKey = 'nigeria';
        break;
      case '+55':
        countryKey = 'brazil';
        break;
      case '+54':
        countryKey = 'argentina';
        break;
      case '+56':
        countryKey = 'chile';
        break;
      case '+57':
        countryKey = 'colombia';
        break;
      case '+52':
        countryKey = 'mexico';
        break;
      case '+31':
        countryKey = 'netherlands';
        break;
      case '+32':
        countryKey = 'belgium';
        break;
      case '+41':
        countryKey = 'switzerland';
        break;
      case '+43':
        countryKey = 'austria';
        break;
      case '+46':
        countryKey = 'sweden';
        break;
      case '+47':
        countryKey = 'norway';
        break;
      case '+45':
        countryKey = 'denmark';
        break;
      case '+358':
        countryKey = 'finland';
        break;
      case '+48':
        countryKey = 'poland';
        break;
      case '+420':
        countryKey = 'czech_republic';
        break;
      case '+36':
        countryKey = 'hungary';
        break;
      case '+30':
        countryKey = 'greece';
        break;
      case '+40':
        countryKey = 'romania';
        break;
      case '+359':
        countryKey = 'bulgaria';
        break;
      case '+351':
        countryKey = 'portugal';
        break;
      case '+353':
        countryKey = 'ireland';
        break;
      case '+972':
        countryKey = 'israel';
        break;
      case '+971':
        countryKey = 'uae';
        break;
      case '+966':
        countryKey = 'saudi_arabia';
        break;
      case '+974':
        countryKey = 'qatar';
        break;
      case '+965':
        countryKey = 'kuwait';
        break;
    }

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
              activeColor: AppTheme.primaryColor,
            ),
            Text(
              code,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isSelected
                    ? Theme.of(context).colorScheme.onBackground
                    : Theme.of(context).unselectedWidgetColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              countryKey.tr,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isSelected
                    ? Theme.of(context).colorScheme.onBackground
                    : Theme.of(context).unselectedWidgetColor,
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

  bool _isFormValid() {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _birthDateController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _selectedGender != null &&
        _agreeToTerms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(.1)))),
          child: AppBar(
            backgroundColor: Theme.of(context).shadowColor.withOpacity(.1),
            shadowColor: Theme.of(context).shadowColor.withOpacity(.1),
            title: Text(
              'new_account'.tr,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'first_name'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                TextFormField(
                  controller: _firstNameController,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: AppTheme.registerInputDecoration(
                    "enter_first_name".tr,
                    context,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'first_name_empty'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'last_name'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                TextFormField(
                  controller: _lastNameController,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: AppTheme.registerInputDecoration(
                    "enter_last_name".tr,
                    context,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'last_name_empty'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'email'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                TextFormField(
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppTheme.registerInputDecoration(
                    "enter_email".tr,
                    context,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'email_empty'.tr;
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'invalid_email'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'birth_date'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                TextFormField(
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: _birthDateController,
                  readOnly: true,
                  decoration: AppTheme.registerInputDecoration(
                    "enter_birth_date".tr,
                    context,
                  ),
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'birth_date_empty'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'phone_number'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                TextFormField(
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    MaskedTextInputFormatter(
                      mask: 'xx xxx xx xx',
                      separator: ' ',
                    ),
                  ],
                  decoration: AppTheme.registerInputDecoration(
                    "XX XXX XX XX",
                    context,
                  ).copyWith(
                    prefixIcon: InkWell(
                      onTap: _showCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "+${_selectedCountry.phoneCode}",
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
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
                    String cleanedValue = value.replaceAll(' ', '');
                    if (cleanedValue.length < 9) {
                      return 'invalid_phone_number'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'gender'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                InkWell(
                  onTap: _showGenderBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0x1A000000), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _selectedGender ?? 'select_gender'.tr,
                          style: TextStyle(
                            color: _selectedGender == null
                                ? Theme.of(context).colorScheme.onBackground
                                : Theme.of(
                                    context,
                                  ).colorScheme.onBackground,
                          ),
                        ),
                        const Spacer(),
                        Image.asset(
                          ImageAssets.careddown,
                          height: 20,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'password'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                TextFormField(
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: AppTheme.registerInputDecoration(
                    "enter_password".tr,
                    context,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.hintColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'password_empty'.tr;
                    }
                    if (value.length < 8) {
                      return 'password_min_length'.tr;
                    }
                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'password_complexity'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'confirm_password'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                TextFormField(
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: AppTheme.registerInputDecoration(
                    "enter_confirm_password".tr,
                    context,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Theme.of(context).hintColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'confirm_password_empty'.tr;
                    }
                    if (value != _passwordController.text) {
                      return 'passwords_dont_match'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'minimum_chars'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).splashColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'minimum_special_char'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).splashColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: 1.4,
                      child: AppTheme.adaptiveCheckbox(
                        borderRadius: BorderRadius.circular(2),
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.to(AppRoutes.terms),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'agree_to_terms1'.tr,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.hyperLinkColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: ' ' + 'agree_to_terms2'.tr,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isFormValid()
                        ? () {
                            if (_formKey.currentState!.validate() &&
                                _agreeToTerms) {
                              Get.toNamed(AppRoutes.emailVerification);
                            } else if (!_agreeToTerms) {
                              SnackbarUtils.showSnackbar(
                                'please_accept_terms'.tr,
                              );
                            }
                          }
                        : null,
                    style: AppTheme.primaryButtonStyle(),
                    child: Text(
                      'create_new_account'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'yes_account'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'login'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
