import '../assets/image_assets.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateQrWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateQrWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).hoverColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    maximumSize: const Size.fromWidth(72),
                  ),
                  icon: Image.asset(
                    ImageAssets.qrcode,
                    height: 33,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  onPressed: onPressed,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'QR kod yarat',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
