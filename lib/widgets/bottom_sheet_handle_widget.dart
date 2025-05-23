import 'package:flutter/material.dart';

class BottomSheetHandleWidget extends StatelessWidget {
  const BottomSheetHandleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
