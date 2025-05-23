import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.headset_mic_outlined,
            size: 23,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        title: Text(
          'support'.tr,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_sharp,
          size: 35,
          color: Theme.of(context).colorScheme.onBackground,
        ),
        // onTap: () => Get.find<HomeController>().navigateToSupport(),
      ),
    );
  }
}
