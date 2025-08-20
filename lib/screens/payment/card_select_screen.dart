import 'dart:convert';
import 'package:avankart_people/screens/main/main_screen.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/widgets/card_tile_widget.dart';
import 'package:flutter/services.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardSelectScreen extends StatefulWidget {
  const CardSelectScreen({super.key});

  @override
  State<CardSelectScreen> createState() => _CardSelectScreenState();
}

class _CardSelectScreenState extends State<CardSelectScreen> {
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
        "status": "waiting",
      },
      {
        "title": "Yanacaq kartı",
        "subtitle":
            "Yanacaq kartı ilə yanacaq doldurma məntəqələrində rahat və endirimli ödəniş edin.",
        "icon": "0xe546",
        "color": "0xff32B5AC",
        "status": "waiting",
      },
      {
        "title": "Market kartı",
        "subtitle":
            "Market kartı gündəlik alış-verişlər üçün sürətli və təhlükəsiz ödəniş imkanı verir.",
        "icon": "0xe8cc",
        "color": "0xff4CAF50",
        "status": "waiting",
      },
      {
        "title": "Əyləncə kartı",
        "subtitle": "Kinoteatr və əyləncə mərkəzlərində istifadə edilə bilər.",
        "icon": "0xe40f",
        "color": "0xff9C27B0",
        "status": "waiting",
      },
      {
        "title": "Səyahət kartı",
        "subtitle":
            "Səyahət zamanı otel və nəqliyyat üçün endirim imkanı təqdim edir.",
        "icon": "0xe539",
        "color": "0xff03A9F4",
        "status": "waiting",
      },
      {
        "title": "Təhsil kartı",
        "subtitle":
            "Kitab, kurs və təhsil platformalarında endirimli ödənişlər üçün.",
        "icon": "0xe80c",
        "color": "0xff00A3FF",
        "status": "waiting",
      },
      {
        "title": "Sağlamlıq kartı",
        "subtitle":
            "Aptek və klinikalarda ödəniş zamanı istifadə üçün nəzərdə tutulub.",
        "icon": "0xe3e5",
        "color": "0xffE91E63",
        "status": "canceled",
      },
      {
        "title": "Geyim kartı",
        "subtitle": "Geyim mağazalarında endirimli alış-veriş üçün.",
        "icon": "0xf582",
        "color": "0xff795548",
        "status": "none",
      },
      {
        "title": "Mobil və İnternet kartı",
        "subtitle": "Mobil və internet xidmətlərinin ödənişini asanlaşdırır.",
        "icon": "0xe1bc",
        "color": "0xff607D8B",
        "status": "none",
      },
      {
        "title": "Xeyriyyə kartı",
        "subtitle":
            "Xeyriyyə fondlarına asan dəstək vermək imkanı təqdim edir.",
        "icon": "0xe89f",
        "color": "0xff8BC34A",
        "status": "none",
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        toolbarHeight: 80,
        centerTitle: false,
        title: Text(
          "cards".tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Container(
            color: Theme.of(context).colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Text(
                "manage_active_cards".tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _cards.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return CardTileWidget(
                  key: ValueKey('card_$index'),
                  title: card['title'],
                  subtitle: card['subtitle'],
                  icon: IconData(
                    int.parse(card['icon']),
                    fontFamily: 'MaterialIcons',
                  ),
                  color: Color(int.parse(card['color'].toString())),
                  value: _switchStates[card['title']] ?? false,
                  status: card['status'],
                  onChanged: (value) => _onSwitchChanged(card['title'], value),
                );
              },
            ),
    );
  }
}
