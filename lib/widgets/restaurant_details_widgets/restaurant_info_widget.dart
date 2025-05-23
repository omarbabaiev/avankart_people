import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantInfoWidget extends StatelessWidget {
  final String name;
  final String description;
  final String rating;
  final bool isOpen;

  const RestaurantInfoWidget({
    Key? key,
    required this.name,
    required this.description,
    required this.rating,
    required this.isOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 50, bottom: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(width: 8),
                    Row(
                      children: [
                        Image.asset(ImageAssets.starIcon,
                            color: Color(0xFFFFC107), height: 24),
                        SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                    color:
                        isOpen ? Colors.green : Theme.of(context).splashColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).hintColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
