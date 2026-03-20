import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  late List data;

  String? selectedLeft;
  Map<String, String> matched = {};

  bool showXp = false;
  int xpGained = 0;
  bool shake = false;

  /// 🔥 MULTI AUDIO (ANTI LAG)
  final AudioPlayer clickPlayer = AudioPlayer();
  final AudioPlayer correctPlayer = AudioPlayer();
  final AudioPlayer wrongPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    data = ref.read(matchingProvider).getData();

    /// 🔥 preload semua audio
    clickPlayer.setAsset('assets/sounds/click.mp3');
    correctPlayer.setAsset('assets/sounds/correct.mp3');
    wrongPlayer.setAsset('assets/sounds/wrong.mp3');
  }

  @override
  void dispose() {
    clickPlayer.dispose();
    correctPlayer.dispose();
    wrongPlayer.dispose();
    super.dispose();
  }

  /// 🔊 AUDIO SUPER SMOOTH
  Future<void> playClick() async {
    try {
      clickPlayer.stop();
      await clickPlayer.seek(Duration.zero);
      clickPlayer.play();
    } catch (_) {}
  }

  Future<void> playCorrect() async {
    try {
      correctPlayer.stop();
      await correctPlayer.seek(Duration.zero);
      correctPlayer.play();
    } catch (_) {}
  }

  Future<void> playWrong() async {
    try {
      wrongPlayer.stop();
      await wrongPlayer.seek(Duration.zero);
      wrongPlayer.play();
    } catch (_) {}
  }

  void selectLeft(String value) async {
    await playClick();
    setState(() => selectedLeft = value);
  }

  void selectRight(String value) async {
    if (selectedLeft == null) return;

    final correct =
        data.firstWhere((e) => e.left == selectedLeft);

    final isCorrect = correct.right == value;

    if (isCorrect) {
      await playCorrect();

      ref.read(gameProvider.notifier).correctAnswer();

      setState(() {
        matched[selectedLeft!] = value;
        selectedLeft = null;

        /// XP aman (tidak spam rebuild)
        if (!showXp) {
          showXp = true;
          xpGained = 10;
        }
      });
    } else {
      await playWrong();

      ref.read(gameProvider.notifier).wrongAnswer();

      setState(() => shake = true);

      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) setState(() => shake = false);
      });

      final game = ref.read(gameProvider);
      if (game.hearts <= 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GameOverScreen()),
        );
        return;
      }

      setState(() => selectedLeft = null);
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => showXp = false);
    });

    /// selesai semua
    if (matched.length == data.length) {
      ref.read(gameProvider.notifier).unlockNextLevel();

      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DecisionScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final progress = matched.length / data.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("POS 3 - Dampak Bencana"),
        centerTitle: true,
      ),
      body: Stack(
        children: [

          /// 🔥 SHAKE RINGAN (LOW COST)
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: shake
                ? Matrix4.translationValues(6, 0, 0)
                : Matrix4.identity(),
            child: Column(
              children: [

                /// HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _badge("❤️ ${game.hearts}", Colors.red),
                          _badge("⭐ ${game.xp}", Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 10),

                      /// 🔥 SMOOTH PROGRESS
                      TweenAnimationBuilder(
                        tween: Tween(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: value,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade300,
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.green),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Cocokkan bencana dengan dampaknya",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Row(
                    children: [

                      /// LEFT SIDE
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final e = data[index];

                            final isSelected =
                                selectedLeft == e.left;
                            final isDone =
                                matched.containsKey(e.left);

                            return KeyedSubtree(
                              key: ValueKey(e.left),
                              child: MatchCard(
                                text: e.left,
                                color: isDone
                                    ? Colors.green
                                    : isSelected
                                        ? Colors.orange
                                        : Colors.white,
                                textColor: isDone || isSelected
                                    ? Colors.white
                                    : Colors.black,
                                border: isSelected,
                                onTap: isDone
                                    ? null
                                    : () => selectLeft(e.left),
                              ),
                            );
                          },
                        ),
                      ),

                      /// RIGHT SIDE
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final e = data[index];

                            final isUsed =
                                matched.containsValue(e.right);

                            return KeyedSubtree(
                              key: ValueKey(e.right),
                              child: MatchCard(
                                text: e.right,
                                color: isUsed
                                    ? Colors.green
                                    : Colors.blue,
                                textColor: Colors.white,
                                onTap: isUsed
                                    ? null
                                    : () => selectRight(e.right),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (showXp) XpPopup(xp: xpGained),
          if (showXp) const ConfettiWidgetCustom(),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
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

/// 🔥 WIDGET TERPISAH (ANTI REBUILD BERAT)
class MatchCard extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final bool border;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    this.border = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: border
              ? Border.all(color: Colors.orange, width: 3)
              : null,
          boxShadow: [
            if (color != Colors.white)
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 3,
                offset: const Offset(2, 3),
              )
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}