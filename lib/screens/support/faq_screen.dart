import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'faq_screen_title'.tr,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'faq'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'support_subtitle'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
              const SizedBox(height: 24),
              _buildFAQCard(
                title: 'faq_question_1'.tr,
                content: 'faq_answer_1'.tr,
                context: context,
              ),
              _buildFAQCard(
                title: 'faq_question_2'.tr,
                content: 'faq_answer_2'.tr,
                context: context,
              ),
              _buildFAQCard(
                title: 'faq_question_5'.tr,
                content: 'faq_answer_5'.tr,
                context: context,
              ),
              _buildFAQCard(
                title: 'faq_question_3'.tr,
                content: 'faq_answer_3'.tr,
                context: context,
              ),
              _buildFAQCard(
                title: 'faq_question_4'.tr,
                content: 'faq_answer_4'.tr,
                context: context,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCard(
      {required String title,
      required String content,
      required BuildContext context}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
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
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          iconColor: Theme.of(context).colorScheme.onBackground,
          collapsedIconColor: Theme.of(context).colorScheme.onBackground,
          childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
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
}
