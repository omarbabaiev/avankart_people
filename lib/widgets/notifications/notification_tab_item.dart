import 'package:flutter/material.dart';

class NotificationTabItem extends StatelessWidget {
  final String text;
  final String count;
  final bool isSelected;
  final VoidCallback onTap;

  const NotificationTabItem({
    super.key,
    required this.text,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
          borderRadius: BorderRadius.circular(4),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(.5),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.onBackground
                        : Theme.of(context).unselectedWidgetColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
