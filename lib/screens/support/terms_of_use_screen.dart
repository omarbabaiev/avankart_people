import '../../utils/conts_texts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../utils/url_utils.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(.1))),
          ),
          child: AppBar(
            backgroundColor: Theme.of(context).shadowColor.withOpacity(.1),
            shadowColor: Theme.of(context).shadowColor.withOpacity(.1),
            centerTitle: false,
            title: Text(
              'terms_of_use'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                'general_terms'.tr,
                'general_terms_content'.tr,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'registration'.tr,
                'registration_content'.tr,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'payment_acceptance'.tr,
                'payment_acceptance_content'.tr,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'user_responsibility'.tr,
                'user_responsibility_content'.tr,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'data_protection'.tr,
                'data_protection_content'.tr,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'restrictions'.tr,
                'restrictions_content'.tr,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'changes'.tr,
                'changes_content'.tr,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'liability_limitation'.tr,
                'liability_limitation_content'.tr,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'complaints'.tr,
                'complaints_content'.tr,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'legal_provisions'.tr,
                'legal_provisions_content'.tr,
              ),
              const SizedBox(height: 16),
              _buildLinkSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 15.3,
            color: Theme.of(context).unselectedWidgetColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

Widget _buildLinkSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "contact_info".tr,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).unselectedWidgetColor,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "email".tr,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).hintColor,
              height: 1.5,
            ),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              UrlUtils.launchEmail(ConstTexts.supportEmail);
            },
            child: Text(
              ConstTexts.supportEmail,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.hyperLinkColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    ],
  );
}
