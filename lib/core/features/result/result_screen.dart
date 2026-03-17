import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 100, color: Colors.amber),
            Text("Selamat!"),
            Text("Siswa Tangguh Bencana"),
          ],
        ),
      ),
    );
  }
}