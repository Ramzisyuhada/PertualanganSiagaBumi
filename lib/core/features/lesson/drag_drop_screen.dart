import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  int part = 1;

  late List questions;

  Map<String, String> userAnswers = {};
  Map<String, bool> correctnessMap = {};

  bool showXp = false;
  int xpGained = 0;
  bool shake = false;

  final targets = ["Banjir", "Longsor", "Gempa"];
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    questions = ref.read(dragDropProvider).getQuestionsByPart(part);

    /// preload audio
    player.setAsset('assets/sounds/click.mp3');
  }

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

  void nextStep() async {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        userAnswers.clear();
        correctnessMap.clear();
      });
    } else {
      if (part < 2) {
        await playSound("levelup.mp3");

        setState(() {
          part++;
          currentIndex = 0;

          questions =
              ref.read(dragDropProvider).getQuestionsByPart(part);

          userAnswers.clear();
          correctnessMap.clear();

          showXp = true;
          xpGained = 50;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🔥 PART $part DIMULAI!"),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MatchingScreen()),
        );
      }
    }
  }

  void checkAnswer(String option, String target) async {
    final question = questions[currentIndex];

    final correct = question.answers[option];
    final isCorrect = correct == target;

    setState(() {
      userAnswers[option] = target;
      correctnessMap[target] = isCorrect;
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

      setState(() => shake = true);

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => shake = false);
      });

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

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => showXp = false);
    });

    /// lanjut kalau semua sudah benar
    final allCorrect = correctnessMap.values
            .where((v) => v == true)
            .length ==
        question.options.length;

    if (allCorrect) {
      Future.delayed(const Duration(milliseconds: 800), nextStep);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _badge("❤️ ${game.hearts}", Colors.red),
                        _badge("⭐ ${game.xp}", Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "PART $part",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TweenAnimationBuilder(
                      tween: Tween(begin: 0.0, end: progress),
                      duration:
                          const Duration(milliseconds: 400),
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                            value: value);
                      },
                    ),
                  ],
                ),
              ),

              /// QUESTION
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  question.question,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),

              /// DRAG ITEMS
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: question.options.map<Widget>((option) {
                    final used =
                        userAnswers.containsKey(option);

                    final isWrong = used &&
                        correctnessMap[userAnswers[option]] ==
                            false;

                    /// 🔒 kalau benar → lock
                    if (used && !isWrong) {
                      return _dragItem(option,
                          disabled: true);
                    }

                    return Draggable<String>(
                      data: option,

                      /// 🔥 kalau di-drag lagi → hapus jawaban lama
                      onDragStarted: () {
                        playSound("click.mp3");

                        if (userAnswers.containsKey(option)) {
                          final oldTarget =
                              userAnswers[option];

                          setState(() {
                            userAnswers.remove(option);
                            correctnessMap
                                .remove(oldTarget);
                          });
                        }
                      },

                      feedback:
                          _dragItem(option, dragging: true),

                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _dragItem(option),
                      ),

                      child: _dragItem(option,
                          isWrong: isWrong),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),

              /// TARGET
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: targets.map((target) {
                    final isFilled =
                        userAnswers.containsValue(target);
                    final isCorrect =
                        correctnessMap[target];

                    Color bgColor = Colors.blue.shade50;
                    Color borderColor = Colors.blue;

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
                      onWillAccept: (_) =>
                          true, // 🔥 boleh override
                      onAccept: (data) =>
                          checkAnswer(data, target),
                      builder: (context, candidateData, _) {
                        final isHovering =
                            candidateData.isNotEmpty;

                        return AnimatedContainer(
                          duration: const Duration(
                              milliseconds: 200),
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16),
                          padding:
                              const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isHovering
                                ? Colors.yellow.shade100
                                : bgColor,
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color: isHovering
                                  ? Colors.orange
                                  : borderColor,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isFilled
                                  ? (isCorrect == true
                                      ? "✔ $target"
                                      : "❌ $target (coba lagi)")
                                  : "Taruh di sini: $target",
                              style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold),
                            ),
                          ),
                        )
                            .animate(target: shake ? 1 : 0)
                            .shake(hz: 4);
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
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _dragItem(String text,
      {bool dragging = false,
      bool disabled = false,
      bool isWrong = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: disabled
            ? null
            : LinearGradient(
                colors: dragging
                    ? [Colors.orange, Colors.deepOrange]
                    : isWrong
                        ? [Colors.red, Colors.redAccent]
                        : [Colors.green, Colors.teal],
              ),
        color: disabled ? Colors.grey : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}