import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LoyaltyCard extends StatelessWidget {
  final String shopName;
  final String description;
  final String cardNumber;
  final Color cardColor;
  final String? logoUrl;

  const LoyaltyCard({
    super.key,
    required this.shopName,
    required this.description,
    required this.cardNumber,
    required this.cardColor,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(cardColor, Colors.white, 0.08)!,
            cardColor,
            Color.lerp(cardColor, Colors.black, 0.15)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            const GrainOverlay(),
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shopName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  Text(
                    cardNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable grain overlay widget.
class GrainOverlay extends StatelessWidget {
  final double opacity;
  const GrainOverlay({super.key, this.opacity = 0.5});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 0.6, sigmaY: 0.6),
            child: CustomPaint(painter: _GrainPainter()),
          ),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  static final Random _random = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const step = 1.5;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        final noise = _random.nextDouble() * 0.06 - 0.03;
        if (noise.abs() < 0.008) continue;
        paint.color = noise > 0
            ? Colors.white.withValues(alpha: noise)
            : Colors.black.withValues(alpha: -noise);
        canvas.drawRect(Rect.fromLTWH(x, y, step, step), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
