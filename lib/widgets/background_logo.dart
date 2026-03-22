import 'package:flutter/material.dart';

class BackgroundLogo extends StatelessWidget {
  final Widget child;

  const BackgroundLogo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          bottom: -15,
          left: 0,
          right: 0,
          child: RepaintBoundary(
            child: Image.asset(
              'assets/images/logo.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.low,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.09),
              colorBlendMode: BlendMode.srcIn,
              cacheWidth: ((MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).toInt()).clamp(1, 4096),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
