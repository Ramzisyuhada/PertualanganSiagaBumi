import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:petualangansiagabumi/core/features/lesson/decision_screen.dart';
import 'package:petualangansiagabumi/core/presentation/widgets/confetti_widget.dart';
import 'package:petualangansiagabumi/core/presentation/widgets/xp_popup.dart';

import 'package:petualangansiagabumi/core/utils/providers.dart';
import 'package:petualangansiagabumi/core/utils/game_provider.dart';

import '../result/game_over_screen.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  String? selectedLeft;
  Map<String, String> matched = {};

  bool showXp = false;
  int xpGained = 0;

  /// 🔊 AUDIO
  final AudioPlayer player = AudioPlayer();

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> playSound(String file) async {
    try {
      await player.stop();
      await player.setAsset('assets/sounds/$file');
      await player.play();
    } catch (e) {
      debugPrint("AUDIO ERROR: $e");
    }
  }

  void selectLeft(String value) async {
    await playSound("click.mp3");

    setState(() {
      selectedLeft = value;
    });
  }

  void selectRight(String value) async {
    if (selectedLeft == null) return;

    final data = ref.read(matchingProvider).getData();

    final correct = data.firstWhere(
      (e) => e.left == selectedLeft,
    );

    final isCorrect = correct.right == value;

    if (isCorrect) {
      await playSound("correct.mp3");

      ref.read(gameProvider.notifier).correctAnswer();

      setState(() {
        matched[selectedLeft!] = value;
        showXp = true;
        xpGained = 10;
      });
    } else {
      await playSound("wrong.mp3");

      ref.read(gameProvider.notifier).wrongAnswer();

      final game = ref.read(gameProvider);

      if (game.hearts <= 0) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GameOverScreen()),
        );
        return;
      }
    }

    /// reset selection
    setState(() {
      selectedLeft = null;
    });

    /// hide xp
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => showXp = false);
    });

    /// selesai semua
    if (matched.length == data.length) {
              ref.read(gameProvider.notifier).unlockNextLevel();

      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DecisionScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(matchingProvider).getData();
    final game = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("POS 3 - Dampak Bencana"),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          Column(
            children: [

              /// 🔝 HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _badge("❤️ ${game.hearts}", Colors.red),
                    _badge("⭐ ${game.xp}", Colors.orange),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Cocokkan bencana dengan dampaknya",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Row(
                  children: [

                    /// LEFT
                    Expanded(
                      child: ListView(
                        children: data.map((e) {
                          final isSelected = selectedLeft == e.left;
                          final isDone = matched.containsKey(e.left);

                          return GestureDetector(
                            onTap: isDone ? null : () => selectLeft(e.left),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? Colors.green.shade100
                                    : isSelected
                                        ? Colors.orange.shade200
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                e.left,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    /// RIGHT
                    Expanded(
                      child: ListView(
                        children: data.map((e) {
                          final isUsed =
                              matched.containsValue(e.right);

                          return GestureDetector(
                            onTap: isUsed ? null : () => selectRight(e.right),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isUsed
                                    ? Colors.green.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                e.right,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// XP
          if (showXp) XpPopup(xp: xpGained),

          /// CONFETTI
          if (showXp) const ConfettiWidgetCustom(),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}