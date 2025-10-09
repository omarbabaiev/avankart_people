import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:avankart_people/models/phone_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyContactWidget extends StatelessWidget {
  final List<PhoneModel>? phones;
  final List<String>? websites;

  const CompanyContactWidget({
    Key? key,
    this.phones,
    this.websites,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "contact".tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: _buildPhoneItems(context),
          ),
        ),
        Container(
          height: 4,
          color: Theme.of(context).colorScheme.secondary,
        ),
        if (websites != null && websites!.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 26, vertical: 20),
            child: Column(
              children: websites!
                  .map(
                    (website) => GestureDetector(
                      onTap: () => _launchUrl(website),
                      child: Row(
                        children: [
                          Image.asset(
                            ImageAssets.linkSimpleIcon,
                            height: 20,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              website,
                              style: TextStyle(
                                color: Theme.of(context).unselectedWidgetColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        Container(
          height: 100,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }

  List<Widget> _buildPhoneItems(BuildContext context) {
    if (phones == null || phones!.isEmpty) {
      return [
        _buildContactItem(
            context, ImageAssets.phoneCallIconDark, 'no_phone_number'.tr),
      ];
    }

    return phones!
        .map(
          (phone) => GestureDetector(
            onTap: () =>
                _makePhoneCall("${phone.prefix ?? ''}${phone.number ?? ''}"),
            child: _buildContactItem(context, ImageAssets.phoneCallIconDark,
                "${phone.prefix ?? ''} ${phone.number ?? ''}"),
          ),
        )
        .toList();
  }

  Widget _buildContactItem(
      BuildContext context, String imagePath, String text) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            height: 20,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      height: 33,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
