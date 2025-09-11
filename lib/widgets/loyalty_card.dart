import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LoyaltyCard extends StatelessWidget {
  final String shopName;
  final String description;
  final String cardNumber;
  final Color cardColor;
  final String? logoUrl;
  final String? category;
  final bool? isFavorite;

  const LoyaltyCard({
    super.key,
    required this.shopName,
    required this.description,
    required this.cardNumber,
    required this.cardColor,
    this.logoUrl,
    this.category,
    this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              shopName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isFavorite == true)
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                        ],
                      ),
                      if (category != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppConstants.categoryIcons[category!],
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                category!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (logoUrl != null)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const Text(
              'Card Number',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              cardNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}