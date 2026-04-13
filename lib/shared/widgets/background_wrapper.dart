import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;

  const BackgroundWrapper({
    super.key,
    required this.child,
    this.overlayOpacity = 0.4, // default cho home
  });

  static const String _bgImage = 'assets/images/background.jpg';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ảnh nền
        Positioned.fill(
          child: Image.asset(
            _bgImage,
            fit: BoxFit.cover,
          ),
        ),
        // Overlay — chỉnh overlayOpacity để mờ/rõ
        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(overlayOpacity),
          ),
        ),
        // Nội dung
        child,
      ],
    );
  }
}