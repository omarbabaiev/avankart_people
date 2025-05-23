import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/widgets/restaurant_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Bəyəndiklərim (6)',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton.filledTonal(
            icon: Image.asset(
              ImageAssets.trophy,
              width: 24,
              height: 24,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            onPressed: () {
              Get.toNamed(AppRoutes.benefits);
            },
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              fixedSize: Size(44, 44),
            ),
          ),
          SizedBox(width: 4),
          IconButton.filledTonal(
            icon: Image.asset(
              ImageAssets.bellInactive,
              width: 24,
              height: 24,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            onPressed: () {
              Get.toNamed(AppRoutes.notifications);
            },
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              fixedSize: Size(44, 44),
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: 4),
          ),
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            title: GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.searchCompany);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        margin: EdgeInsets.symmetric(vertical: 4),
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Theme.of(context)
                                  .bottomNavigationBarTheme
                                  .unselectedItemColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Material(
                              child: Text(
                                'Restoran, müəssisə...',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .bottomNavigationBarTheme
                                      .unselectedItemColor
                                      ?.withOpacity(.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.filterSearch);
                      },
                      child: Container(
                        height: 44,
                        width: 44,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          ImageAssets.funnel,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Header

          SliverToBoxAdapter(
            child: SizedBox(height: 50),
          ),

          // Restaurant List
          SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 1.5,
              crossAxisSpacing: 0,
              childAspectRatio: 0.68,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final List<Map<String, dynamic>> restaurants = [
                {
                  'name': 'Özsüt Restoran',
                  'location': 'Bakı, Malakan',
                  'distance': '1.2 km',
                  'isOpen': true,
                  'hasGift': false,
                  'type': 'restaurant',
                },
                {
                  'name': 'Özsüt Restoran',
                  'location': 'Bakı, Malakan',
                  'distance': '1.2 km',
                  'isOpen': true,
                  'hasGift': true,
                  'type': 'petrol',
                },
                {
                  'name': 'Özsüt Restoran',
                  'location': 'Bakı, Malakan',
                  'distance': '1.2 km',
                  'isOpen': true,
                  'hasGift': false,
                  'type': 'cafe',
                },
                {
                  'name': 'Özsüt Restoran',
                  'location': 'Bakı, Malakan',
                  'distance': '1.2 km',
                  'isOpen': true,
                  'hasGift': false,
                  'type': 'restaurant',
                },
                {
                  'name': 'Özsüt Restoran',
                  'location': 'Bakı, Malakan',
                  'distance': '1.2 km',
                  'isOpen': true,
                  'hasGift': false,
                  'type': 'petrol',
                },
                {
                  'name': 'Özsüt Restoran',
                  'location': 'Bakı, Malakan',
                  'distance': '1.2 km',
                  'isOpen': true,
                  'hasGift': false,
                  'type': 'cafe',
                },
              ];

              final restaurant = restaurants[index];
              return RestaurantCard(
                name: restaurant['name'].toString(),
                location: restaurant['location'].toString(),
                distance: restaurant['distance'].toString(),
                imageUrl: 'assets/images/image.png',
                isOpen: restaurant['isOpen'] as bool,
                hasGift: restaurant['hasGift'] as bool,
                type: restaurant['type'],
                index: index,
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 150,
            ),
          )
        ],
      ),
    );
  }
}
