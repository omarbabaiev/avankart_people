import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData? icon;

  const CategoryItem({
    required this.name,
    this.icon,
  });
}

class RestaurantCategoryWidget extends StatelessWidget {
  final List<CategoryItem> categories;

  const RestaurantCategoryWidget({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories
            .map((category) => _buildCategoryItem(context, category))
            .toList(),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryItem category) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (category.icon != null) ...[
            Icon(
              category.icon,
              color: Theme.of(context).colorScheme.onBackground,
              size: 20,
            ),
            SizedBox(width: 6),
          ],
          Text(
            category.name,
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
}
