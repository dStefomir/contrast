import 'package:flutter/material.dart';

/// Custom widget that renders a house
class HouseShape extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path
    ..moveTo(size.width / 2, 0)
    ..lineTo(size.width, size.height * 0.331)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..lineTo(0, size.height * 0.331)
    ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
/// Custom shadow of the house widget
class HouseShadowPainter extends CustomPainter {
  
  @override
  void paint(Canvas canvas, Size size) {
    final Path shadowPath = Path();
    shadowPath
      ..moveTo(size.width / 2, -3)
      ..lineTo(size.width, size.height * 0.331)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height * 0.331)
      ..close();

    canvas.drawShadow(shadowPath, Colors.black, 1, true);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}