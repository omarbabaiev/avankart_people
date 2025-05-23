import 'dart:convert';
import 'package:avankart_people/screens/main/main_screen.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/widgets/card_tile_widget.dart';
import 'package:avankart_people/widgets/initial_card_tile_widget.dart';
import 'package:flutter/services.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class InitialCardScreen extends StatefulWidget {
  const InitialCardScreen({super.key});

  @override
  State<InitialCardScreen> createState() => _InitialCardScreenState();
}

class _InitialCardScreenState extends State<InitialCardScreen> {
  final Map<String, bool> _switchStates = {};
  List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  // Switch durumlarını kontrol eden fonksiyon
  bool get _isAnyCardSelected => _switchStates.values.any((value) => value);

  void _loadCards() {
    _cards = [
      {
        "title": "Yemək kartı",
        "subtitle":
            "Yemək kartı, sizlərin restoran və kafelərdə rahat və sürətli ödəniş etməniz üçündür.",
        "icon": "0xe56c",
        "color": "0xffFFBC0D",
      },
      {
        "title": "Yanacaq kartı",
        "subtitle":
            "Yanacaq kartı ilə yanacaq doldurma məntəqələrində rahat və endirimli ödəniş edin.",
        "icon": "0xe546",
        "color": "0xff32B5AC",
      },
      {
        "title": "Market kartı",
        "subtitle":
            "Market kartı gündəlik alış-verişlər üçün sürətli və təhlükəsiz ödəniş imkanı verir.",
        "icon": "0xe8cc",
        "color": "0xff4CAF50",
      },
      {
        "title": "Əyləncə kartı",
        "subtitle": "Kinoteatr və əyləncə mərkəzlərində istifadə edilə bilər.",
        "icon": "0xe40f",
        "color": "0xff9C27B0",
      },
      {
        "title": "Səyahət kartı",
        "subtitle":
            "Səyahət zamanı otel və nəqliyyat üçün endirim imkanı təqdim edir.",
        "icon": "0xe539",
        "color": "0xff03A9F4",
      },
      {
        "title": "Təhsil kartı",
        "subtitle":
            "Kitab, kurs və təhsil platformalarında endirimli ödənişlər üçün.",
        "icon": "0xe80c",
        "color": "0xff00A3FF",
      },
      {
        "title": "Sağlamlıq kartı",
        "subtitle":
            "Aptek və klinikalarda ödəniş zamanı istifadə üçün nəzərdə tutulub.",
        "icon": "0xe3e5",
        "color": "0xffE91E63",
      },
      {
        "title": "Geyim kartı",
        "subtitle": "Geyim mağazalarında endirimli alış-veriş üçün.",
        "icon": "0xf582",
        "color": "0xff795548",
      },
      {
        "title": "Mobil və İnternet kartı",
        "subtitle": "Mobil və internet xidmətlərinin ödənişini asanlaşdırır.",
        "icon": "0xe1bc",
        "color": "0xff607D8B",
      },
      {
        "title": "Xeyriyyə kartı",
        "subtitle":
            "Xeyriyyə fondlarına asan dəstək vermək imkanı təqdim edir.",
        "icon": "0xe89f",
        "color": "0xff8BC34A",
      },
    ];

    // Her kart için başlangıç switch durumunu false olarak ayarla
    for (var card in _cards) {
      _switchStates[card['title']] = false;
    }
  }

  void _onSwitchChanged(String title, bool value) {
    setState(() {
      _switchStates[title] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        centerTitle: true,
        title: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "cards".tr,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    "using_cards".tr,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "skip".tr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _cards.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return InitialCardTileWidget(
                  key: ValueKey('card_$index'),
                  title: card['title'],
                  subtitle: card['subtitle'],
                  icon: IconData(
                    int.parse(card['icon']),
                    fontFamily: 'MaterialIcons',
                  ),
                  color: Color(int.parse(card['color'].toString())),
                  value: _switchStates[card['title']] ?? false,
                  onChanged: (value) => _onSwitchChanged(card['title'], value),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 40,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: ElevatedButton(
          onPressed: _isAnyCardSelected
              ? () {
                  _acceptBottomSheet(context);
                }
              : () {},
          style: AppTheme.primaryButtonStyle(isDisabled: !_isAnyCardSelected),
          child: Text("next".tr, style: AppTheme.buttonTextStyle),
        ),
      ),
    );
  }

  void _acceptBottomSheet(BuildContext context) {
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
                  color: Color(0x15F9B200),
                  shape: BoxShape.circle,
                ),
                child: Transform.rotate(
                  angle: 3.14,
                  child: Icon(
                    Icons.logout_outlined,
                    color: Color(0xffF9B100),
                    size: 24,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "selected_cards_activate".tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "selected_cards_activate_info".tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => MainScreen());
                  },
                  style: AppTheme.primaryButtonStyle(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(
                    'confirm'.tr,
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
                  'cancel'.tr,
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
