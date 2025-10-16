import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:cached_network_svg_image/cached_network_svg_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardInfoScreen extends StatefulWidget {
  final Color? cardColor;
  final String? cardTitle;
  final String? cardIcon;
  final String? cardDescription;

  const CardInfoScreen({
    Key? key,
    this.cardColor,
    this.cardTitle,
    this.cardIcon,
    this.cardDescription,
  }) : super(key: key);

  @override
  State<CardInfoScreen> createState() => _CardInfoScreenState();
}

class _CardInfoScreenState extends State<CardInfoScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // UI'yi güncellemek için setState çağır
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.cardColor ?? Colors.blue,
      ),
      child: Stack(
        children: [
          FadeInImage(
            placeholder: AssetImage(ImageAssets.background),
            image: AssetImage(ImageAssets.background),
            fit: BoxFit.cover,
          ),
          SafeArea(
            bottom: false,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  // Header
                  _buildHeader(context),
                  // Main Content
                  Expanded(
                    child: _buildMainContent(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Status bar
          SizedBox(height: 20),
          // Navigation and title
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Text(
                'usage_rules'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.98,
      minChildSize: 0.98,
      maxChildSize: 0.98,
      snap: true,
      snapAnimationDuration: const Duration(milliseconds: 1000),
      builder: (BuildContext context, ScrollController scrollController) {
        return Hero(
          tag: Get.arguments?['heroTag'] ?? 'card_info',
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  // Card Info Section
                  _buildCardInfoSection(context),
                  Divider(
                    indent: 24,
                    endIndent: 24,
                    color:
                        Theme.of(context).unselectedWidgetColor.withOpacity(.5),
                    height: 0.3,
                  ),
                  SizedBox(height: 25),
                  // Tabs
                  _buildTabs(context),
                  // Content
                  Expanded(
                    child: _buildContent(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardInfoSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // Card Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: widget.cardColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkSVGImage(
                  'https://api.avankart.com/v1/icon/${widget.cardIcon}',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  placeholder: Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                    size: 24,
                  ),
                  errorWidget: Icon(
                    Icons.credit_card,
                    color: Colors.black,
                    size: 24,
                  ),
                  color: Colors.black,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          // Card Title
          Text(
            widget.cardTitle ?? 'card'.tr,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onBackground,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 12),
          // Card Description
          Text(
            widget.cardDescription ?? 'no_available'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).unselectedWidgetColor,
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 24,
      ),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Usage Rules Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(0);
              },
              child: Container(
                height: 37,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  color: _tabController.index == 0
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: _tabController.index == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'usage_rules'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _tabController.index == 0
                        ? Theme.of(context).colorScheme.onBackground
                        : Theme.of(context).unselectedWidgetColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          // Categories Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(1);
              },
              child: Container(
                height: 37,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  color: _tabController.index == 1
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: _tabController.index == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'categories'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _tabController.index == 1
                        ? Theme.of(context).colorScheme.onBackground
                        : Theme.of(context).unselectedWidgetColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildUsageRulesContent(context),
          _buildCategoriesContent(context),
        ],
      ),
    );
  }

  Widget _buildUsageRulesContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'food_card_usage_rule'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          _buildExpansionTileCard(
              title: 'card_restaurant_only'.tr,
              content: 'card_restaurant_only'.tr,
              context: context),
          _buildExpansionTileCard(
              title: 'balance_warning'.tr,
              content: 'balance_warning'.tr,
              context: context),
          _buildExpansionTileCard(
              title: 'partner_validity'.tr,
              content: 'partner_validity'.tr,
              context: context),
        ],
      ),
    );
  }

  Widget _buildCategoriesContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'categories'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'coming_soon'.tr,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildExpansionTileCard({
  required String title,
  required String content,
  required BuildContext context,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        iconColor: Theme.of(context).colorScheme.onBackground,
        collapsedIconColor: Theme.of(context).colorScheme.onBackground,
        childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        expandedAlignment: Alignment.centerLeft,
        children: [
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).unselectedWidgetColor,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    ),
  );
}
