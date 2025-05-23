import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/screens/other/restoraunt_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantCard extends StatelessWidget {
  final String name;
  final int index;
  final String location;
  final String distance;
  final String imageUrl;
  final bool isOpen;
  final bool hasGift;
  final String type;

  const RestaurantCard({
    Key? key,
    required this.name,
    required this.index,
    required this.location,
    required this.distance,
    required this.imageUrl,
    required this.type,
    this.isOpen = true,
    this.hasGift = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.restaurantDetail);
      },
      child: Container(
        height: 200,
        margin: EdgeInsets.only(bottom: 3),
        padding: EdgeInsets.only(
            left: index % 2 == 0 ? 16 : 6,
            right: index % 2 == 0 ? 6 : 16,
            top: 14),
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.onPrimary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(.2),
                    ),
                    onPressed: () {},
                    icon: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(.9),
                          Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(.3),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 4,
                  child: Row(
                    children: [
                      Image.asset(ImageAssets.distanceIcon,
                          color: Colors.white, height: 16),
                      SizedBox(width: 4),
                      Text(
                        distance,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Restaurant Info
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        location,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: IgnorePointer(
                          ignoring: true,
                          child: ToggleButtons(
                            onPressed: (int index) {
                              // handle state update here
                            },
                            fillColor: Theme.of(context).colorScheme.secondary,
                            constraints: BoxConstraints(
                              maxHeight: 32,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            children: [
                              switch (type) {
                                'restaurant' => Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Icon(Icons.restaurant_menu,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  ),
                                'petrol' => Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Icon(Icons.local_gas_station,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  ),
                                'cafe' => Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Icon(Icons.coffee,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  ),
                                _ => Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Icon(Icons.place,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                                  ),
                              },
                              if (hasGift) ...[
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.card_giftcard,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                              ],
                            ],
                            isSelected: [
                              true,
                              if (hasGift) ...[true],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? Color(0xFF23A26D).withOpacity(0.12)
                              : Color(0xFF000000).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOpen ? 'Açıq' : 'Bağlı',
                          style: TextStyle(
                            color: isOpen
                                ? Colors.green
                                : Theme.of(context).splashColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
