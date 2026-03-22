import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> cardBackgroundColors = [
    '#004C99', // Blue
    '#B82D2D', // Red
    '#1D7A45', // Green
    '#7A3F94', // Purple
    '#C07A0A', // Orange
    '#0F7A63', // Teal
    '#B5174E', // Pink
    '#2574A8', // Light Blue
    '#22994F', // Light Green
    '#C49A0C', // Yellow
    '#263545', // Dark Gray
    '#0F8A74', // Turquoise
  ];

  // Shopping list categories
  static const List<String> shoppingCategories = [
    'Groceries',
    'Electronics',
    'Clothing',
    'Home',
    'Health',
    'Other',
  ];

  static const Map<String, IconData> shoppingCategoryIcons = {
    'Groceries': Icons.shopping_basket,
    'Electronics': Icons.devices,
    'Clothing': Icons.checkroom,
    'Home': Icons.home,
    'Health': Icons.medical_services,
    'Other': Icons.category,
  };

  static const Map<String, Color> shoppingCategoryColors = {
    'Groceries': Colors.green,
    'Electronics': Colors.blue,
    'Clothing': Colors.purple,
    'Home': Colors.orange,
    'Health': Colors.red,
    'Other': Colors.grey,
  };
}
