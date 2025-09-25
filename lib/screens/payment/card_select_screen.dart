import 'package:avankart_people/controllers/card_manage_controller.dart';
import 'package:avankart_people/widgets/card_tile_widget.dart';
import 'package:avankart_people/models/card_models.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:io';

class CardSelectScreen extends StatelessWidget {
  final cardManagerController = Get.put(CardManageController());

  CardSelectScreen({Key? key}) : super(key: key) {
    // Controller'ı initialize et

    // Sadece ilk kez açıldığında kart verilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Eğer kart data yoksa yükle
      if (cardManagerController.allCards.isEmpty) {
        cardManagerController.loadAllCards(refresh: true);
      }
    });
  }

  // Get card icon based on icon name - now returns the icon name string directly
  String _getCardIcon(String iconName) {
    return iconName; // Return the icon name directly for dynamic URL usage
  }

  // Parse hex color string to Color
  Color _parseHexColor(String hexColor) {
    try {
      // Remove # if present
      String hex = hexColor.startsWith('#') ? hexColor.substring(1) : hexColor;
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppTheme.primaryColor; // Default green color
    }
  }

  // Handle card selection
  void _onCardSelectionChanged(String cardId, bool value) {
    final cardController = Get.find<CardManageController>();
    cardController.toggleCardSelection(cardId);
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
        toolbarHeight: 68,
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
          preferredSize: Size.fromHeight(20),
          child: Container(
            color: Theme.of(context).colorScheme.secondary,
            alignment: Alignment.centerLeft,
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
      body: Obx(() {
        final cards = cardManagerController.allCards;
        final isLoading = cardManagerController.isLoadingAllCards;

        // Loading false ve cards empty true ise empty state göster
        if (!isLoading && cards.isEmpty) {
          return _buildEmptyState(context);
        }

        return Skeletonizer(
          enabled: isLoading || cards.isEmpty,
          enableSwitchAnimation: true,
          child: Platform.isIOS
              ? CustomScrollView(
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () async {
                        await cardManagerController.loadAllCards(refresh: true);
                      },
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (cards.isEmpty) {
                            return _buildSkeletonCard(context);
                          }

                          final card = cards[index];

                          // Print log for each card
                          debugPrint('📱 Kart Yüklendi:');
                          debugPrint('   İsim: ${card.name}');
                          debugPrint('   isActive: ${card.isActive}');
                          debugPrint('   Status: ${card.currentStatus}');
                          debugPrint('   ID: ${card.id}');
                          debugPrint('   ---');

                          return CardTileWidget(
                            key: ValueKey('card_${card.id}'),
                            title: card.name,
                            subtitle: card.description ?? card.name,
                            icon: _getCardIcon(card.icon),
                            color: _parseHexColor(card.backgroundColor),
                            value:
                                cardManagerController.selectedCards[card.id] ??
                                    false,
                            status: card.currentStatus,
                            isActive: card.isActive,
                            conditions: card.conditions,
                            cardId: card.id,
                            onChanged: (value) =>
                                _onCardSelectionChanged(card.id, value),
                          );
                        },
                        childCount: cards.isEmpty ? 12 : cards.length,
                      ),
                    ),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await cardManagerController.loadAllCards(refresh: true);
                  },
                  child: ListView.builder(
                    itemCount: cards.isEmpty ? 12 : cards.length,
                    itemBuilder: (context, index) {
                      if (cards.isEmpty) {
                        return _buildSkeletonCard(context);
                      }

                      final card = cards[index];

                      // Print log for each card
                      debugPrint('📱 Kart Yüklendi:');
                      debugPrint('   İsim: ${card.name}');
                      debugPrint('   isActive: ${card.isActive}');
                      debugPrint('   Status: ${card.currentStatus}');
                      debugPrint('   ID: ${card.id}');
                      debugPrint('   ---');

                      return CardTileWidget(
                        key: ValueKey('card_${card.id}'),
                        title: card.name,
                        subtitle: card.description ?? card.name,
                        icon: _getCardIcon(card.icon),
                        color: _parseHexColor(card.backgroundColor),
                        value: cardManagerController.selectedCards[card.id] ??
                            false,
                        status: card.currentStatus,
                        isActive: card.isActive,
                        conditions: card.conditions,
                        cardId: card.id,
                        onChanged: (value) =>
                            _onCardSelectionChanged(card.id, value),
                      );
                    },
                  ),
                ),
        );
      }),
    );
  }

  // Build empty state widget
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImageAssets.cardholder,
              width: 80,
              height: 80,
              color: Theme.of(context).unselectedWidgetColor,
            ),
            const SizedBox(height: 16),
            Text(
              'no_cards_found'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'no_cards_available_message'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
            const SizedBox(height: 24),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
              onPressed: () async {
                await cardManagerController.loadAllCards(refresh: true);
              },
              child: Text(
                'refresh'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build skeleton card widget
  Widget _buildSkeletonCard(BuildContext context) {
    return CardTileWidget(
      key: const Key('skeleton_card'),
      title: 'card_name',
      subtitle: 'card_description',
      icon: _getCardIcon('card_icon'),
      color: _parseHexColor('card_background_color'),
      value: false,
      status: 'card_status',
      isActive: false,
      conditions: const <CardCondition>[],
      cardId: 'skeleton_card_id',
      onChanged: (value) => _onCardSelectionChanged('card_id', value),
    );
  }
}
