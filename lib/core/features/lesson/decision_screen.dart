import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:petualangansiagabumi/core/features/quiz/quiz_screen.dart';

import 'package:petualangansiagabumi/core/utils/game_provider.dart';
import 'package:petualangansiagabumi/data/models/DecisionQuestion.dart';

class DecisionScreen extends ConsumerStatefulWidget {
  const DecisionScreen({super.key});

  @override
  ConsumerState<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends ConsumerState<DecisionScreen>
    with TickerProviderStateMixin {
  int sectionIndex = 0;
  int questionIndex = 0;

  int? selectedIndex;
  bool answered = false;
  bool isLocked = false; // 🔥 anti spam tap

  final AudioPlayer player = AudioPlayer();

  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();

    player.setVolume(1.0);

    /// 🔊 PRELOAD AUDIO (ANTI LAG)
    _preloadAudio();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..forward();
  }

  Future<void> _preloadAudio() async {
    try {
      await player.setAsset('assets/sounds/click.mp3');
    } catch (_) {}
  }

  @override
  void dispose() {
    player.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// 🔊 PLAY SOUND (NO LAG)
  Future<void> playSound(String file) async {
    try {
      await player.stop();
      await player.setAsset('assets/sounds/$file');
      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      debugPrint("AUDIO ERROR: $e");
    }
  }

  int get totalQuestions {
    return decisionData.fold(
        0, (sum, section) => sum + section.questions.length);
  }

  int get currentQuestionNumber {
    int count = 0;
    for (int i = 0; i < sectionIndex; i++) {
      count += decisionData[i].questions.length;
    }
    return count + questionIndex + 1;
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    final section = decisionData[sectionIndex];
    final question = section.questions[questionIndex];

    final progress = currentQuestionNumber / totalQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(section.title),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [

          /// 🌈 HEADER
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
                const SizedBox(height: 12),

                /// 🔥 SMOOTH PROGRESS
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 10,
                    );
                  },
                ),

                const SizedBox(height: 6),
                Text(
                  "$currentQuestionNumber / $totalQuestions",
                  style: const TextStyle(fontSize: 12),
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// 🧠 QUESTION CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedScale(
              scale: answered ? 0.98 : 1,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFF8FAFF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10)
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
          ),

          const SizedBox(height: 20),

          /// 🎯 OPTIONS
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
                    if (answered || isLocked) return;

                    isLocked = true;

                    await playSound("click.mp3");

                    setState(() {
                      selectedIndex = i;
                      answered = true;
                    });

                    if (i == question.correctIndex) {
                      ref.read(gameProvider.notifier).correctAnswer();
                      await playSound("correct.mp3");
                    } else {
                      ref.read(gameProvider.notifier).wrongAnswer();
                      await playSound("wrong.mp3");
                    }

                    await Future.delayed(
                        const Duration(milliseconds: 800));

                    nextStep();
                    isLocked = false;
                  },

                  child: AnimatedScale(
                    scale: isSelected ? 0.97 : 1,
                    duration: const Duration(milliseconds: 150),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: borderColor, width: 2),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void nextStep() async{
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

         Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const QuizScreen()),
        );
    }
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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