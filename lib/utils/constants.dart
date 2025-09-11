import 'package:flutter/material.dart';

class AppConstants {
  // Card Categories
  static const List<String> cardCategories = [
    'Grocery',
    'Fashion',
    'Food',
    'Restaurant',
    'Entertainment',
    'Health',
    'Travel',
    'Other',
  ];
  
  // Category Icons
  static const Map<String, IconData> categoryIcons = {
    'Grocery': Icons.shopping_cart,
    'Fashion': Icons.shopping_bag,
    'Food': Icons.fastfood,
    'Restaurant': Icons.restaurant,
    'Entertainment': Icons.movie,
    'Health': Icons.local_hospital,
    'Travel': Icons.flight,
    'Other': Icons.loyalty,
  };
  
  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Grocery': Colors.green,
    'Fashion': Colors.purple,
    'Food': Colors.orange,
    'Restaurant': Colors.red,
    'Entertainment': Colors.blue,
    'Health': Colors.teal,
    'Travel': Colors.indigo,
    'Other': Colors.grey,
  };
}