import 'package:avankart_people/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../assets/image_assets.dart';
import '../../utils/conts_texts.dart';
import '../../utils/url_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/support_widgets/support_contact_card.dart';
import 'faq_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'support'.tr,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'support'.tr,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'support_subtitle'.tr,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SupportSocialCard(
                      icon: Icons.facebook,
                      title: 'facebook'.tr,
                      onTap: () => Get.to(() => const FAQScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SupportSocialCard(
                      icon: Icons.facebook,
                      title: 'facebook'.tr,
                      onTap: () => Get.to(() => const FAQScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SupportContactCard(
                icon: ImageAssets.question,
                title: 'faq'.tr,
                onTap: () => Get.toNamed(AppRoutes.faq),
              ),
              const SizedBox(height: 16),
              SupportContactCard(
                icon: ImageAssets.envelope2,
                title: 'sorgu'.tr,
                onTap: () => Get.toNamed(AppRoutes.query),
              ),
              const SizedBox(height: 16),
              SupportContactCard(
                icon: ImageAssets.phoneCall,
                title: 'hotline'.tr,
                subtitle: ConstTexts.supportPhone,
                onTap: () async {
                  await UrlUtils.launchPhone(ConstTexts.supportPhone);
                },
              ),
              const SizedBox(height: 16),
              SupportContactCard(
                icon: ImageAssets.envelope2,
                title: 'email'.tr,
                subtitle: ConstTexts.supportEmail,
                onTap: () => UrlUtils.launchEmail(ConstTexts.supportEmail),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
