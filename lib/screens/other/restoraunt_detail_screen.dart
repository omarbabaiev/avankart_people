import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avankart_people/widgets/restaurant_details_widgets/restaurant_header_widget.dart';
import 'package:avankart_people/widgets/restaurant_details_widgets/restaurant_info_widget.dart';
import 'package:avankart_people/widgets/restaurant_details_widgets/restaurant_action_buttons_widget.dart';
import 'package:avankart_people/widgets/restaurant_details_widgets/restaurant_address_widget.dart';
import 'package:avankart_people/widgets/restaurant_details_widgets/restaurant_working_hours_widget.dart';
import 'package:avankart_people/widgets/restaurant_details_widgets/restaurant_social_media_widget.dart';
import 'package:avankart_people/widgets/restaurant_details_widgets/restaurant_contact_widget.dart';
import 'package:avankart_people/widgets/restaurant_details_widgets/restaurant_category_widget.dart';

class RestorauntDetailScreen extends StatelessWidget {
  const RestorauntDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 60,
        elevation: 0,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 80,
        leading: IconButton.filledTonal(
          style: IconButton.styleFrom(
            maximumSize: Size(44, 44),
            backgroundColor:
                Theme.of(context).colorScheme.onPrimary.withOpacity(.3),
          ),
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
        ),
        actions: [
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              padding: EdgeInsets.all(10),
              backgroundColor:
                  Theme.of(context).colorScheme.onPrimary.withOpacity(.2),
            ),
            onPressed: () {},
            icon: Icon(
              Icons.favorite_border_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantHeaderWidget(
              imageUrl: "assets/images/image.png",
              distance: "1.2 km",
            ),
            RestaurantInfoWidget(
              name: "Özsüt Restoran",
              description:
                  "ÖzSüt-ün hekayəsi İzmir Kemeraltında 16 kv. metrlik bir məkanda başlayıb. Daha sonra Səfər ustanın yolu Osmanlı sarayından çıxan bir usta ilə kəsişir. Bu 1938-ci ilə təsadüf edir.",
              rating: "4.8",
              isOpen: false,
            ),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            RestaurantActionButtonsWidget(),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            RestaurantAddressWidget(
              address: "Azerbaycan, Bakı şəhəri, Nərimanov rayonu",
            ),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            RestaurantWorkingHoursWidget(),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            RestaurantCategoryWidget(
              categories: [
                CategoryItem(
                  name: "Yemək",
                  icon: Icons.medical_services_outlined,
                ),
                CategoryItem(
                  name: "Nahar",
                ),
                CategoryItem(
                  name: "Şirniyyat",
                  icon: Icons.cake,
                ),
                CategoryItem(
                  name: "İçki",
                  icon: Icons.local_drink,
                ),
              ],
            ),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            RestaurantCategoryWidget(
              categories: [
                CategoryItem(
                  name: "Yemək",
                ),
              ],
            ),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            RestaurantSocialMediaWidget(),
            Container(
              height: 4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            RestaurantContactWidget(),
          ],
        ),
      ),
    );
  }
}
