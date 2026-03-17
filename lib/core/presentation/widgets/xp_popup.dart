import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class XpPopup extends StatelessWidget {
  final int xp;

  const XpPopup({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "+$xp XP",
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      )
          .animate()
          .scale(duration: 300.ms)
          .fadeIn()
          .then()
          .moveY(begin: 0, end: -80, duration: 800.ms)
          .fadeOut(),
    );
  }
}