import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LevelBubble extends StatelessWidget {
  final String title;
  final bool unlocked;
  final VoidCallback onTap;

  const LevelBubble({
    required this.title,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? Colors.green : Colors.grey.shade400,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(
              unlocked ? Icons.star : Icons.lock,
              color: Colors.white,
              size: 30,
            ),
          )
              .animate()
              .scale(duration: 400.ms)
              .then()
              .shake(hz: unlocked ? 0 : 2),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}