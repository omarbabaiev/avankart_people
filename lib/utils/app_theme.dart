import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:avankart_people/utils/vibration_util.dart';

class AppTheme {
  // Color Palette - Light & Dark
  static const String currencySymbol = '₼';

  // Primary Colors
  static const Color primaryColor = Color(0xFF745086); // Primary
  static const Color hoverButton = Color(0xFF88649A); // Hover Button
  static const Color focusColor = Color(0xFF9C78AE); // Focus Color
  static const Color hoverButton10 = Color(0x1A88649A); // Hover Button 10%

  // Text Colors
  static const Color primaryTextColor = Color(0xFF1D222B); // Primary Text Color
  static const Color secondaryTextColor = Color(
    0x651D222B,
  ); // Secondary Text Color
  static const Color tertiaryTextColor = Color(
    0x501D222B,
  ); // Tertiary Text Color
  static const Color disabledTextColor = Color(
    0xFFFFFFFF,
  ); // Text Disabled Color
  static const Color textColor = primaryTextColor; // General Text Color

  // Background Colors
  static const Color white = Color(0xFFFFFFFF); // White/Body BG
  static const Color black = Color(0xFF000000); // Black/Stroke Color
  static const Color backgroundColor = white; // Body BG
  static const Color surfaceColor = Color(0xFFF8F9FF); // Surface
  static const Color sidebarBG = Color(0xFFFAFAFA); // SideBar BG
  static const Color surfaceDim = Color(0xFFD8DAE0); // Surface Dim
  static const Color surfaceBright = Color(0xFFF8F9FF); // Surface Bright
  static const Color container = Color(0xFFECEEF4); // Container
  static const Color containerLow = Color(0xFFF2F3FA); // Container Low
  static const Color containerLowest = Color(0xFFFFFFFF); // Container Lowest
  static const Color lightGray = Color(
    0xFFF8F9FA,
  ); // Light Gray (For Legacy Code)
  static const Color lightGray2 = Color(
    0xFFF5F6F7,
  ); // Light Gray 2 (For Legacy Code)

  // UI Element Colors
  static const Color selectedColor = Color(0xFFF4F4F4); // Selected Color
  static const Color strokeColor = Color(0x1A000000); // Stroke Color
  static const Color outlineColor = Color(0xFF70787C); // Outline
  static const Color outlineVariant = Color(0xFFBFC8CC); // Outline Variant
  static const Color image = Color(0xFFFAFAFA); // Image
  static const Color itemHover = Color(0xFFF6F6F6); // Item Hover
  static const Color tableHover = Color(0xFFF5F5F5); // Table Hover
  static const Color surfaceVariant = Color(0xFFDBE4E8); // Surface Variant
  static const Color onSurfaceVariant = Color(0xFF40484C); // On Surface Variant
  static const Color switchColor = Color(0xFFE0E0E0); // Switch
  static const Color dragHandleColor = Color(0xFFE0E0E0); // Drag Handle

  // Settings UI Colors
  static const Color settingsCardBg = white; // Settings Card Background
  static const Color settingsDivider = Color(0xFFEEEEEE); // Settings Divider
  static const Color settingsIconBg = Color(
    0xFFF5F5F5,
  ); // Settings Icon Background
  static const Color settingsIconColor = Color(
    0xFF505050,
  ); // Settings Icon Color
  static const Color splashBackground = primaryColor; // Splash Background

  // Status Colors
  static const Color successColor = Color(0xFF5BBE2D); // Success Color Primary
  static const Color successMessagesColor = Color(
    0x185BBE2D,
  ); // Success Messages BG
  static const Color error = Color(0xFFDD3838); // Error
  static const Color errorHover = Color(0x1EDD3838); // Error Hover
  static const Color redColor = Color(0xFFDD3838); // Error/Red
  static const Color blueColor = Color(0xFF007AFF); // Blue
  static const Color warningColor = Color(0xFFFFC107); // Warning
  static const Color infoColor = Color(0xFF2196F3); // Info
  static const Color orangeColor = Color(0xFFE67E22); // Orange
  static const Color yellowColor = Color(0xFFF1C40F); // Yellow
  static const Color greenColor = Color(0xFF2ECC71); // Green
  static const Color errorColor = redColor; // Error Color (Alias)

  // Dark Theme Specific Colors
  static const Color darkBackgroundColor = Color(0xFF0F171B); // Dark Surface
  static const Color darkSurface = Color(0xFF111418); // Dark Surface
  static const Color darkContainer = Color(0xFF1D2024); // Dark Container
  static const Color darkContainer2 = Color(0xFF1D2024); // Dark Container 2
  static const Color darkMenu = Color(0xFF10181C); // Dark Menu
  static const Color darkSidebarBG = Color(0xFF0C1418); // Dark Sidebar BG
  static const Color darkBodyBG = Color(0xFF070F13); // Dark Body BG
  static const Color darkonSurface = Color(0xFFE1E2E8); // Dark onSurface
  static const Color darkonSurfaceVariant = Color(
    0xFFBFC8CC,
  ); // Dark onSurfaceVariant
  static const Color darkTextColor = Color(0xFFFFFFFF); // Dark Text Color
  static const Color darkPrimaryTextColor = Color(
    0xFFFFFFFF,
  ); // Dark Primary Text
  static const Color darkSecondaryTextColor = Color(
    0x97FFFFFF,
  ); // Dark Secondary Text
  static const Color darkTertiaryTextColor = Color(
    0x50FFFFFF,
  ); // Dark Tertiary Text
  static const Color darkStrokeColor = Color(0x1AFFFFFF); // Dark Stroke Color
  static const Color darkHintColor = Color(0x7AFFFFFF); // Dark Hint Color
  static const Color darkHintAccent = Color(0x97FFFFFF); // Dark Hint Accent
  static const Color darkHoverButton = Color(0xFF88649A); // Dark Hover Button
  static const Color darkHoverButton10 = Color(
    0x33A890BB,
  ); // Dark Hover Button 10%
  static const Color darkError = Color(0xFFE03B3B); // Dark Error
  static const Color darkErrorHover = Color(0x1FF06262); // Dark Error Hover
  static const Color darkDragHandleColor = Color(
    0xFF343C40,
  ); // Dark Drag Handle

  // Profile UI Colors
  static const Color profileInitialsBg = Color(
    0x4D88649A,
  ); // Profile Initials Background
  static const Color profileInitialsColor = Color(
    0xFF88649A,
  ); // Profile Initials Text Color
  static const Color logoutIconColor = error; // Logout Icon Color

  // Other UI Colors
  static const Color buttonDisabled = Color(0x4D88649A); // Button Disabled
  static const Color blackTransparent10 = Color(0x1A000000); // 10% Black
  static const Color blackTransparent12 = Color(0x1F000000); // 12% Black
  static const Color hoverButton1 = Color(0xFF88649A); // Hover Button 1
  static const Color bottomNavigationUnselectedColor = Color(
    0xFF70787C,
  ); // Bottom Navigation Unselected
  static const Color snackBarSuccesColor = Color(
    0xFF3498DB,
  ); // Snackbar Success

  // Light Theme Utilities
  static const Color hintColor = Color(0xFF8B96A5); // Hint Color
  static const Color hintAccent = Color(0xFFBFC8CC); // Hint Accent
  static const Color accentPurple = Color(0xFF88649A); // Accent Purple
  static const Color accentPrimaryColor = accentPurple; // Accent Primary
  static const Color hyperLinkColor = Color(0xFF2F80ED); // Hyperlink
  static const Color notificationActionColor =
      primaryColor; // Notification Action

  // getX renk metodları kullanılmadan eşitlenen statik renkler
  // Bu renkleri direkt kullanarak Get.isDarkMode ile dinamik
  // renkler oluşturmak yerine statik renklere geçiş yapılabilir

  // getTextColor yerine kullanılacak
  // static const Color textColor = primaryTextColor; // zaten var

  // getIconColor yerine kullanılacak
  static const Color iconColor = primaryTextColor;

  // getSurfaceColor yerine kullanılacak
  // static const Color surfaceColor = surfaceColor; // zaten var

  // getBackgroundColor yerine kullanılacak
  // static const Color backgroundColor = white; // zaten var

  // getPrimaryTextColor yerine kullanılacak
  // static const Color primaryTextColor = ... // zaten var

  // getSecondaryTextColor yerine kullanılacak
  // static const Color secondaryTextColor = ... // zaten var

  // getTertiaryTextColor yerine kullanılacak
  // static const Color tertiaryTextColor = ... // zaten var

  // getIconBackgroundColor yerine kullanılacak
  static const Color iconBackgroundColor = settingsIconBg;

  // getHintColor yerine kullanılacak
  // static const Color hintColor = ... // zaten var

  // getCardColor yerine kullanılacak
  static const Color cardColor = white;

  // getDividerColor yerine kullanılacak
  // static const Color dividerColor = settingsDivider; // zaten var

  // Register Input Decoration
  static InputDecoration registerInputDecoration(
    String hintText,
    BuildContext context,
  ) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
          fontFamily: 'Poppins',
          color: Theme.of(context).hintColor.withOpacity(.4),
          fontSize: 14),
      filled: false,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorStyle: TextStyle(
        fontFamily: 'Poppins',
        color: Theme.of(context).colorScheme.error,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: Theme.of(context).shadowColor.withOpacity(.7), width: 1),
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
    );
  }

  // Dark/Light tema geçişleri için yardımcı metotlar

  // Tema değiştiricileri
  static ThemeData get lightTheme => ThemeData(
        dividerColor: Color(0x16000000),
        iconTheme: IconThemeData(color: primaryTextColor),
        textTheme: TextTheme().apply(
          bodyColor: primaryTextColor,
          displayColor: primaryTextColor,
          fontFamily: 'Poppins',
        ),
        primaryTextTheme: TextTheme().apply(
          bodyColor: primaryTextColor,
          displayColor: primaryTextColor,
          fontFamily: 'Poppins',
        ),
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          tertiaryContainer: tableHover,
          primary: primaryColor,
          onPrimary: white,
          secondary: image,
          onSecondary: white,
          background: backgroundColor,
          onBackground: primaryTextColor,
          surface: surfaceColor,
          onSurface: primaryTextColor,
          error: error,
          onError: Color(0x16DD3838),
          secondaryContainer: Color(0xffEFF0F7),
        ),
        dialogBackgroundColor: Color(0xfffffffff),
        hoverColor: hoverButton10,
        hintColor: Color(0xff70787C),
        splashColor: const Color(0x7A1D222B),
        unselectedWidgetColor: Color(0x991D222B),
        shadowColor: Color(0xffBFC8CC),
        scaffoldBackgroundColor: Color(0xffFAFAFA),
        primaryColor: primaryColor,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: primaryTextColor),
          titleTextStyle: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          backgroundColor: const Color(0xFFFAFAFA),
          selectedLabelStyle: TextStyle(
            fontSize: 10,
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 10,
            color: Color(0xFF70787C),
            fontWeight: FontWeight.w600,
          ),
          selectedItemColor: AppTheme.primaryTextColor,
          unselectedItemColor: Color(0xff70787C),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: white,
            minimumSize: Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primaryColor),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: primaryTextColor,
            backgroundColor: Colors.transparent,
          ),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: primaryColor,
          unselectedLabelColor: secondaryTextColor,
          indicatorColor: primaryColor,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return white;
          }),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          hintStyle: TextStyle(color: hintAccent),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0x1A000000), width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor, width: 1),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return hintAccent;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor.withOpacity(0.5);
            }
            return hintAccent.withOpacity(0.5);
          }),
        ),
        dividerTheme: DividerThemeData(color: settingsDivider, thickness: 1),
        cardTheme: CardThemeData(
          color: white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        dividerColor: Color(0x15FFFFFF),
        iconTheme: IconThemeData(color: primaryTextColor),
        textTheme: TextTheme().apply(
          bodyColor: primaryTextColor,
          displayColor: primaryTextColor,
          fontFamily: 'Poppins',
        ),
        primaryTextTheme: TextTheme().apply(
          bodyColor: primaryTextColor,
          displayColor: primaryTextColor,
          fontFamily: 'Poppins',
        ),
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          onPrimary: Color(0xff161E22),
          secondary: Color(0xff1C2428),
          onSecondary: white,
          background: backgroundColor,
          onBackground: white,
          surface: surfaceColor,
          onSurface: primaryTextColor,
          error: error,
          onError: Color(0x16DD3838),
          secondaryContainer: Color(0xff2E3135),
        ),
        dialogBackgroundColor: Color(0xff161E22),
        hoverColor: hoverButton10,
        hintColor: Color(0xff8A9296),
        splashColor: const Color(0x7CFFFFFF),
        unselectedWidgetColor: Color(0xA3FFFFFF),
        shadowColor: Color(0xff2E3135),
        scaffoldBackgroundColor: darkBackgroundColor,
        primaryColor: primaryColor,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: darkBackgroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: white),
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            color: white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          backgroundColor: const Color(0xFF0C1418),
          selectedLabelStyle: TextStyle(
            fontSize: 10,
            color: white,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 10,
            color: Color(0xff8A9296),
            fontWeight: FontWeight.w600,
          ),
          selectedItemColor: white,
          unselectedItemColor: Color(0xff8A9296),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: white,
            minimumSize: Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primaryColor),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: primaryTextColor,
            backgroundColor: Colors.transparent,
          ),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: primaryColor,
          unselectedLabelColor: secondaryTextColor,
          indicatorColor: primaryColor,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return white;
          }),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          hintStyle: TextStyle(color: hintAccent),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0x1A000000), width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor, width: 1),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return hintAccent;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor.withOpacity(0.5);
            }
            return hintAccent.withOpacity(0.5);
          }),
        ),
        dividerTheme: DividerThemeData(color: settingsDivider, thickness: 1),
        cardTheme: CardThemeData(
          color: white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  // Platform kontrol
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  // Adaptif ikonlar
  static IconData adaptiveVisibilityIcon(bool isVisible) {
    return isIOS
        ? isVisible
            ? CupertinoIcons.eye
            : CupertinoIcons.eye_slash
        : isVisible
            ? Icons.visibility
            : Icons.visibility_off;
  }

  // Adaptif widget'lar
  static Widget adaptiveActivityIndicator() {
    return isIOS
        ? const CupertinoActivityIndicator()
        : const CircularProgressIndicator();
  }

  static Widget adaptiveButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return isIOS
        ? CupertinoButton(
            color: backgroundColor ?? primaryColor,
            disabledColor: AppTheme.buttonDisabled,
            onPressed: () {
              // Button tıklama - haptic feedback
              VibrationUtil.lightVibrate();
              onPressed();
            },
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : ElevatedButton(
            onPressed: () {
              // Button tıklama - haptic feedback
              VibrationUtil.lightVibrate();
              onPressed();
            },
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: AppTheme.buttonDisabled,
              backgroundColor: backgroundColor ?? primaryColor,
              foregroundColor: textColor ?? white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
  }

  static Widget adaptiveSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return isIOS
        ? CupertinoSwitch(
            value: value,
            onChanged: (newValue) {
              // Switch değişimi - haptic feedback
              VibrationUtil.selectionVibrate();
              onChanged(newValue);
            },
            activeColor: primaryColor,
          )
        : Switch(
            value: value,
            onChanged: (newValue) {
              // Switch değişimi - haptic feedback
              VibrationUtil.selectionVibrate();
              onChanged(newValue);
            },
            activeColor: primaryColor);
  }

  static Widget adaptiveCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    Color? activeColor,
    double? size,
    BorderRadius? borderRadius,
  }) {
    return SizedBox(
      width: size ?? 30,
      height: size ?? 30,
      child: Checkbox.adaptive(
        hoverColor: Color(0xfff7f7f7),
        checkColor: AppTheme.sidebarBG,
        value: value,
        onChanged: (newValue) {
          // Checkbox değişimi - haptic feedback
          VibrationUtil.selectionVibrate();
          onChanged(newValue);
        },
        activeColor: activeColor ?? primaryColor,
        fillColor: MaterialStateProperty.resolveWith<Color>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.selected)) {
            return activeColor ?? primaryColor;
          }
          return lightGray2;
        }),
        side: const BorderSide(color: Color(0xFFDBE4E8), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  static Widget adaptiveTextField({
    required TextEditingController controller,
    String? placeholder,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return isIOS
        ? CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            obscureText: obscureText,
            keyboardType: keyboardType,
            suffix: suffix,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
          )
        : TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            decoration: inputDecoration(
              placeholder ?? '',
              false,
            ).copyWith(suffixIcon: suffix),
          );
  }

  // Default text styles
  static TextStyle get defaultTextStyle => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: textColor,
        fontWeight: FontWeight.w400,
      );

  // Metin stilleri
  static TextStyle get headingStyle => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      );

  static TextStyle get subheadingStyle => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        color: hintColor,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get buttonTextStyle => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: white,
      );

  static TextStyle get linkStyle => TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: primaryColor,
        fontWeight: FontWeight.w500,
      );

  // Buton stilleri
  static ButtonStyle primaryButtonStyle({
    bool isDisabled = false,
    Color? backgroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor:
          isDisabled ? Color(0x37745086) : backgroundColor ?? primaryColor,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      elevation: 0,
    );
  }

  // Input dekorasyon
  static InputDecoration inputDecoration(String hintText, bool isDark) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: hintAccent),
      filled: false,
      fillColor: isDark ? surfaceColor : Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorStyle: TextStyle(fontFamily: 'Poppins', color: errorColor),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: blackTransparent10, // Siyah renk %10 opaklık
          width: 1,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 1),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
    );
  }
}
