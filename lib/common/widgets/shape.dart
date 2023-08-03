import 'package:flutter/material.dart';

/// Custom widget that renders a house
class HouseShape extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height * .25)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height * .25)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
/// Custom shadow of the house widget
class HouseShadowPainter extends CustomPainter {
  
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    path
      ..moveTo(size.width / 2 + 1, -1)
      ..lineTo(size.width + 1, size.height * .25 -1)
      ..lineTo(size.width + 1, size.height -1)
      ..lineTo(0, size.height -1)
      ..lineTo(0, size.height * .23 -1)
      ..close();

    canvas.drawShadow(path, Colors.black, 2, true);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
/// Custom widget that renders a triangle
class TriangleShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 1.5);
    path.lineTo(size.width, size.height * 1.5);
    path.lineTo(size.width / 2, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
/// Custom shadow of the triangle widget
class TriangleShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height * 1.5);
    path.lineTo(size.width, size.height * 1.5);
    path.lineTo(size.width / 2, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}