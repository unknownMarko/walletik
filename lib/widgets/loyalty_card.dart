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

/// Reusable grain overlay widget. Uses a single cached texture for all instances.
class GrainOverlay extends StatelessWidget {
  final double opacity;
  const GrainOverlay({super.key, this.opacity = 0.5});

  static ui.Image? _cachedTexture;
  static bool _generating = false;

  static Future<ui.Image> _generateTexture() async {
    const size = 64;
    final random = Random(42);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    for (int x = 0; x < size; x += 3) {
      for (int y = 0; y < size; y += 3) {
        final noise = random.nextDouble() * 0.05 - 0.025;
        if (noise.abs() < 0.006) continue;
        paint.color = noise > 0
            ? Color.fromRGBO(255, 255, 255, noise)
            : Color.fromRGBO(0, 0, 0, -noise);
        canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 3, 3), paint);
      }
    }

    final picture = recorder.endRecording();
    return picture.toImage(size, size);
  }

  static Future<void> warmUp() async {
    if (_cachedTexture != null || _generating) return;
    _generating = true;
    _cachedTexture = await _generateTexture();
    _generating = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedTexture == null) {
      warmUp().then((_) {
        // Trigger rebuild via framework — texture will be ready next frame
        (context as Element).markNeedsBuild();
      });
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: CustomPaint(
            painter: _CachedGrainPainter(_cachedTexture!),
          ),
        ),
      ),
    );
  }
}

class _CachedGrainPainter extends CustomPainter {
  final ui.Image texture;

  _CachedGrainPainter(this.texture);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.none;
    final src = Rect.fromLTWH(0, 0, texture.width.toDouble(), texture.height.toDouble());

    // Tile the texture across the entire area
    for (double x = 0; x < size.width; x += texture.width) {
      for (double y = 0; y < size.height; y += texture.height) {
        final dst = Rect.fromLTWH(x, y, texture.width.toDouble(), texture.height.toDouble());
        canvas.drawImageRect(texture, src, dst, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CachedGrainPainter oldDelegate) => oldDelegate.texture != texture;
}
