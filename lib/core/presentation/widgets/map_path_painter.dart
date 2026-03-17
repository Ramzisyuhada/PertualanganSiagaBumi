import 'package:flutter/material.dart';

class MapPathPainter extends CustomPainter {
  final int total;
  final double animationValue;

  MapPathPainter({
    required this.total,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double spacing = 160;

    for (int i = 0; i < total - 1; i++) {
      final startX = (i % 2 == 0) ? 70.0 : size.width - 70;
      final startY = i * spacing + 80;

      final endX = ((i + 1) % 2 == 0) ? 70.0 : size.width - 70;
      final endY = (i + 1) * spacing + 80;

      final controlX = size.width / 2;
      final controlY = (startY + endY) / 2;

      path.moveTo(startX, startY);
      path.quadraticBezierTo(controlX, controlY, endX, endY);
    }

    final dashWidth = 10.0;
    final dashSpace = 8.0;

    final metrics = path.computeMetrics();

    for (var metric in metrics) {
      double distance = animationValue * 30;

      while (distance < metric.length) {
        final segment =
            metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapPathPainter oldDelegate) => true;
}