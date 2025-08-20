import 'package:flutter/material.dart';

class SkeletonizerNotificationItem extends StatelessWidget {
  const SkeletonizerNotificationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Theme.of(context).colorScheme.secondary,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Icon(
            Icons.notifications,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        title: Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 12,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 10,
              width: 80,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
