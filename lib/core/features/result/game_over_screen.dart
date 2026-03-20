import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petualangansiagabumi/core/utils/game_provider.dart';
import '../home_map/map_screen.dart';

class GameOverScreen extends ConsumerWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFE0E0),
              Color(0xFFFFF3F3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// 💔 ICON ANIMASI
              Icon(Icons.favorite, size: 100, color: Colors.red)
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    duration: 800.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                  )
                  .then()
                  .scale(
                    duration: 800.ms,
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1, 1),
                  ),

              const SizedBox(height: 20),

              /// TITLE
              const Text(
                "💀 Kamu Kehabisan Nyawa!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// SUBTITLE
              const Text(
                "Tenang... kamu bisa coba lagi 💪",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              /// 📊 STATS CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text("⭐ XP: ${game.xp}"),
                    const SizedBox(height: 5),
                    Text("🏆 Level: ${game.level}"),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// 🔁 RETRY BUTTON (PRIMARY)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  ref.read(gameProvider.notifier).resetGame();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "🔁 Coba Lagi",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 12),

              /// 🗺️ BACK TO MAP (SECONDARY)
              TextButton(
                onPressed: () {
                  ref
                      .read(gameProvider.notifier)
                      .gameOverButKeepProgress();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Kembali ke Map",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}