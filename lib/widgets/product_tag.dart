import 'package:flutter/material.dart';

class ProductTag extends StatelessWidget {
  final String type; // 'cart' or 'owner'
  final Color backgroundColor;
  final Color iconColor;

  const ProductTag({
    super.key,
    required this.type,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    if (type == 'cart') {
      icon = Icons.shopping_cart;
    } else {
      icon = Icons.person;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 16,
      ),
    );
  }
}
