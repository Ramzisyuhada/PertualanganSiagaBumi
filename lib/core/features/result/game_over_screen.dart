import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petualangansiagabumi/core/utils/game_provider.dart';
import '../home_map/map_screen.dart';

class GameOverScreen extends ConsumerWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 100, color: Colors.red),

            const SizedBox(height: 20),

            const Text(
              "Game Over",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text("XP kamu: ${game.xp}"),

            const SizedBox(height: 30),

            /// 🔁 RETRY
            ElevatedButton(
              onPressed: () {
                ref.read(gameProvider.notifier).resetGame();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => MapScreen()),
                  (route) => false,
                );
              },
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }
}