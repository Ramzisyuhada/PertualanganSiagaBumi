import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class InteractiveCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const InteractiveCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,

      front: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Tap untuk lihat", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),

      back: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(12),
        child: Center(
          child: Text(
            description,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}