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

  // Card Background Colors (Predefined Palette)
  static const List<String> cardBackgroundColors = [
    '#0066CC', // Blue
    '#E74C3C', // Red
    '#27AE60', // Green
    '#9B59B6', // Purple
    '#F39C12', // Orange
    '#16A085', // Teal
    '#E91E63', // Pink
    '#3498DB', // Light Blue
    '#2ECC71', // Light Green
    '#F1C40F', // Yellow
    '#34495E', // Dark Gray
    '#1ABC9C', // Turquoise
  ];
}