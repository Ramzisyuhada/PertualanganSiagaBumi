import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool opened;
  final bool isAnimating;
  final VoidCallback onTap;

  const LessonCard({
    required this.title,
    required this.icon,
    required this.opened,
    required this.onTap,
    required this.isAnimating,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isAnimating ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: opened
                ? Colors.green.shade100
                : isAnimating
                    ? Colors.green.shade50
                    : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: opened
                ? Border.all(color: Colors.green, width: 2)
                : isAnimating
                    ? Border.all(color: Colors.green, width: 2)
                    : null,
            boxShadow: [
              BoxShadow(
                color: isAnimating
                    ? Colors.green.withOpacity(0.3)
                    : Colors.black12,
                blurRadius: isAnimating ? 12 : 8,
              )
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (opened)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}