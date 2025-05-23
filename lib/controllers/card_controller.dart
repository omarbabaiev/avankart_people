import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CardController extends GetxController with SingleGetTickerProviderMixin {
  final RxDouble balance = 148.50.obs;
  final RxList transactions = [].obs;
  final RxBool isBottomSheetExpanded = false.obs;

  final RxInt selectedIndex = 0.obs;
  late PageController pageController;

  // Kartlar
  final RxList<Map<String, dynamic>> cards = <Map<String, dynamic>>[
    {
      'title': 'Gümüş Kart',
      'icon': 'assets/images/Silver.png',
      'color': const Color(0xFFB0BEC5),
      'balance': 148.50,
    },
    {
      'title': 'Qızıl Kart',
      'icon': 'assets/images/Gold.png',
      'color': const Color(0xFFFFD700),
      'balance': 320.00,
    },
    {
      'title': 'Platin Kart',
      'icon': 'assets/images/Platinum.png',
      'color': const Color(0xFFE5E4E2),
      'balance': 975.00,
    },
    {
      'title': 'Platin Kart',
      'icon': 'assets/images/Platinum.png',
      'color': const Color(0xFFE5E4E2),
      'balance': 975.00,
    },
    {
      'title': 'Platin Kart',
      'icon': 'assets/images/Platinum.png',
      'color': const Color(0xFFE5E4E2),
      'balance': 975.00,
    },
    {
      'title': 'Platin Kart',
      'icon': 'assets/images/Platinum.png',
      'color': const Color(0xFFE5E4E2),
      'balance': 975.00,
    },
    {
      'title': 'Platin Kart',
      'icon': 'assets/images/Platinum.png',
      'color': const Color(0xFFE5E4E2),
      'balance': 975.00,
    },
    {
      'title': 'Platin Kart',
      'icon': 'assets/images/Platinum.png',
      'color': const Color(0xFFE5E4E2),
      'balance': 975.00,
    },
  ].obs;

  late DraggableScrollableController dragController;
  late AnimationController animationController;
  late Animation<double> sizeAnimation;
  late Animation<double> textSizeAnimation;
  late Animation<double> fadeAnimation;

  @override
  void onInit() {
    super.onInit();

    pageController = PageController();
    dragController = DraggableScrollableController();
    dragController.addListener(_onDragUpdate);

    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    sizeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    textSizeAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    transactions.value = [
      {
        'type': 'reward',
        'title': '20 dəfə ye, 5 AZN qazan',
        'subtitle': 'Mükafatlar',
        'amount': '+5.00',
        'date': 'Bu gün',
        'icon': 'assets/images/Silver.png',
        'isPositive': true
      },
      {
        'type': 'restaurant',
        'title': 'Özsüt Restoran',
        'subtitle': 'Restoran və kafe',
        'amount': '22.80',
        'date': 'Bu gün',
        'icon': 'assets/images/Silver.png',
        'isPositive': false
      },
      {
        'type': 'restaurant',
        'title': 'Özsüt Restoran',
        'subtitle': 'Restoran və kafe',
        'amount': '12.80',
        'date': 'Bu gün',
        'icon': 'assets/images/Silver.png',
        'isPositive': false
      },
      {
        'type': 'topup',
        'title': 'Veysəloğlu MMC',
        'subtitle': 'Balans artımı',
        'amount': '+150.00',
        'date': 'Dünən',
        'icon': 'assets/images/Silver.png',
        'isPositive': true
      },
      {
        'type': 'restaurant',
        'title': 'Özsüt Restoran',
        'subtitle': 'Restoran və kafe',
        'amount': '22.80',
        'date': 'Dünən',
        'icon': 'assets/images/Silver.png',
        'isPositive': false
      },
      {
        'type': 'restaurant',
        'title': 'Özsüt Restoran',
        'subtitle': 'Restoran və kafe',
        'amount': '-7.50',
        'date': 'Dünən',
        'icon': 'assets/images/Silver.png',
        'isPositive': false
      }
    ];
  }

  void _onDragUpdate() {
    final bool shouldExpand = dragController.size > 0.75;
    isBottomSheetExpanded.value = shouldExpand;

    if (shouldExpand) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  void onCardChanged(int index) {
    selectedIndex.value = index;
    animationController.forward(from: 0);
  }

  void increaseBalance(double amount) {
    balance.value += amount;
  }

  void addTransaction(Map<String, dynamic> transaction) {
    transactions.insert(0, transaction);
  }

  @override
  void onClose() {
    pageController.dispose();
    dragController.dispose();
    animationController.dispose();
    super.onClose();
  }
}
