import 'package:flutter/material.dart';

class AppConstants {
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