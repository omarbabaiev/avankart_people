import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:avankart_people/widgets/restaurant_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar: AppBar(
          toolbarHeight: 68,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Baku, Azerbaijan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                fixedSize: Size(44, 44),
              ),
              icon: Image.asset(
                ImageAssets.heartStraight,
                width: 24,
                height: 24,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              onPressed: () {
                Get.toNamed(AppRoutes.favorites);
              },
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
                Get.toNamed(AppRoutes.benefits);
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
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              title: GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.searchCompany);
                },
                child: Hero(
                  tag: 'search_company',
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
                                Image.asset(
                                  ImageAssets.searchNormal,
                                  width: 24,
                                  height: 24,
                                  color: Theme.of(context)
                                      .bottomNavigationBarTheme
                                      .unselectedItemColor,
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
            ),

            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 5, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Müəssisələr',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showMenu(
                          menuPadding: EdgeInsets.all(5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          color: Theme.of(context).colorScheme.secondary,
                          context: context,
                          position: RelativeRect.fromLTRB(1, 250, 0, 0),
                          items: [
                            PopupMenuItem(
                              value: 0,
                              child: Text(
                                'A-Z',
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 1,
                              child: Text(
                                'Məsafəyə görə',
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      icon: Image.asset(
                        ImageAssets.sortAscending,
                        width: 24,
                        height: 24,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      label: Text(
                        'Sırala',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 5),
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
      ),
    );
  }
}
