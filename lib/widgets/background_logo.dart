import 'package:flutter/material.dart';

class BackgroundLogo extends StatelessWidget {
  final Widget child;

  const BackgroundLogo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background logo
        Positioned(
          bottom: -15, // Move logo down to start from bottom navbar level
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 0.3,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
