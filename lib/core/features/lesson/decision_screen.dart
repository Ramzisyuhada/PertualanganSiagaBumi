import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:petualangansiagabumi/core/utils/game_provider.dart';
import 'package:petualangansiagabumi/data/models/DecisionQuestion.dart';

class DecisionScreen extends ConsumerStatefulWidget {
  const DecisionScreen({super.key});

  @override
  ConsumerState<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends ConsumerState<DecisionScreen> {
  int sectionIndex = 0;
  int questionIndex = 0;

  int? selectedIndex;
  bool answered = false;

  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    player.setVolume(1.0);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  /// 🔊 PLAY SOUND (FIXED)
  Future<void> playSound(String file) async {
    try {
      await player.stop(); // 🔥 penting biar tidak overlap
      await player.setAsset('assets/sounds/$file');
      await player.play();
    } catch (e) {
      debugPrint("AUDIO ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    final section = decisionData[sectionIndex];
    final question = section.questions[questionIndex];

    final progress = ((sectionIndex * 2) + questionIndex + 1) /
        (decisionData.length * 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(section.title),
        centerTitle: true,
      ),

      body: Stack(
        children: [

          /// MAIN UI
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
                        _badge("⭐ ${game.xp} XP", Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: progress),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// QUESTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// OPTIONS
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, i) {
                    final isSelected = selectedIndex == i;
                    final isCorrect = i == question.correctIndex;

                    Color bgColor = Colors.white;
                    Color borderColor = Colors.grey.shade300;

                    if (answered) {
                      if (isCorrect) {
                        bgColor = Colors.green.shade100;
                        borderColor = Colors.green;
                      } else if (isSelected) {
                        bgColor = Colors.red.shade100;
                        borderColor = Colors.red;
                      }
                    } else if (isSelected) {
                      bgColor = Colors.blue.shade100;
                      borderColor = Colors.blue;
                    }

                    return GestureDetector(
                      onTap: () async {
                        if (answered) return;

                        /// 🔊 CLICK
                        await playSound("click.mp3");

                        setState(() {
                          selectedIndex = i;
                          answered = true;
                        });

                        if (i == question.correctIndex) {
                          ref.read(gameProvider.notifier).correctAnswer();

                          /// 🔊 CORRECT
                          await playSound("correct.mp3");
                        } else {
                          ref.read(gameProvider.notifier).wrongAnswer();

                          /// 🔊 WRONG
                          await playSound("wrong.mp3");
                        }

                        Future.delayed(const Duration(seconds: 1), () {
                          nextStep();
                        });
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: Text(
                          question.options[i],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          /// 💥 CINEMATIC FLASH
          if (answered)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: selectedIndex == question.correctIndex
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
            ),
        ],
      ),
    );
  }

  void nextStep() {
    setState(() {
      selectedIndex = null;
      answered = false;
    });

    final section = decisionData[sectionIndex];

    if (questionIndex < section.questions.length - 1) {
      questionIndex++;
    } else if (sectionIndex < decisionData.length - 1) {
      sectionIndex++;
      questionIndex = 0;
    } else {
      ref.read(gameProvider.notifier).unlockNextLevel();

      Navigator.pop(context);
    }
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