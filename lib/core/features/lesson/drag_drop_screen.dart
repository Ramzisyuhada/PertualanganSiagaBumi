import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:petualangansiagabumi/core/utils/providers.dart';
import 'package:petualangansiagabumi/core/utils/game_provider.dart';

import 'package:petualangansiagabumi/core/presentation/widgets/xp_popup.dart';
import 'package:petualangansiagabumi/core/presentation/widgets/confetti_widget.dart';

import 'matching_screen.dart';
import '../result/game_over_screen.dart';

class DragDropScreen extends ConsumerStatefulWidget {
  const DragDropScreen({super.key});

  @override
  ConsumerState<DragDropScreen> createState() => _DragDropScreenState();
}

class _DragDropScreenState extends ConsumerState<DragDropScreen> {
  int currentIndex = 0;

  /// user answer
  Map<String, String> userAnswers = {};

  /// highlight status
  Map<String, bool> correctnessMap = {};

  bool showXp = false;
  int xpGained = 0;

  final targets = ["Banjir", "Longsor", "Gempa"];

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

  void checkAnswer(String option, String target) async {
    final question =
        ref.read(dragDropProvider).getQuestions()[currentIndex];

    final correct = question.answers[option];
    final isCorrect = correct == target;

    setState(() {
      userAnswers[option] = target;
      correctnessMap[target] = isCorrect; // 🔥 highlight
    });

    if (isCorrect) {
      await playSound("correct.mp3");

      ref.read(gameProvider.notifier).correctAnswer();

      setState(() {
        showXp = true;
        xpGained = 10;
      });
    } else {
      await playSound("wrong.mp3");

      ref.read(gameProvider.notifier).wrongAnswer();

      final game = ref.read(gameProvider);

      if (game.hearts <= 0) {
        ref.read(gameProvider.notifier).unlockNextLevel();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GameOverScreen()),
        );
        return;
      }
    }

    /// hide xp
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => showXp = false);
    });

    /// ✅ lanjut kalau semua sudah dijawab
    if (userAnswers.length == question.options.length) {
      Future.delayed(const Duration(milliseconds: 800), () {
        final total =
            ref.read(dragDropProvider).getQuestions().length;

        if (currentIndex < total - 1) {
          setState(() {
            currentIndex++;
            userAnswers.clear();
            correctnessMap.clear();
          });
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MatchingScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(dragDropProvider).getQuestions();
    final question = questions[currentIndex];

    final game = ref.watch(gameProvider);
    final progress = (currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("POS 2 - Interaktif"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [

              /// HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _badge("❤️ ${game.hearts}", Colors.red),
                        _badge("⭐ ${game.xp}", Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: progress),
                  ],
                ),
              ),

              /// QUESTION
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  question.question,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              /// DRAG ITEMS
              Wrap(
                spacing: 12,
                children: question.options.map((option) {
                  final used = userAnswers.containsKey(option);

                  return Draggable<String>(
                    data: option,
                    onDragStarted: () => playSound("click.mp3"),
                    feedback: _dragItem(option, dragging: true),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _dragItem(option),
                    ),
                    child: _dragItem(option, disabled: used),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              /// TARGET
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: targets.map((target) {
                    final isFilled = userAnswers.containsValue(target);
                    final isCorrect = correctnessMap[target];

                    Color bgColor = Colors.blue.shade50;
                    Color borderColor = Colors.blue;

                    /// 🔥 HIGHLIGHT
                    if (isFilled) {
                      if (isCorrect == true) {
                        bgColor = Colors.green.shade100;
                        borderColor = Colors.green;
                      } else {
                        bgColor = Colors.red.shade100;
                        borderColor = Colors.red;
                      }
                    }

                    return DragTarget<String>(
                      onAccept: isFilled
                          ? null
                          : (data) => checkAnswer(data, target),
                      builder: (context, candidateData, rejectedData) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              isFilled
                                  ? (isCorrect == true
                                      ? "✔ $target"
                                      : "❌ $target")
                                  : "Taruh di sini: $target",
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          if (showXp) XpPopup(xp: xpGained),
          if (showXp) const ConfettiWidgetCustom(),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _dragItem(String text,
      {bool dragging = false, bool disabled = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: disabled
            ? Colors.grey
            : dragging
                ? Colors.orange
                : Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}