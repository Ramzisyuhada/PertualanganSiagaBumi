import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:petualangansiagabumi/core/utils/game_provider.dart';
import 'package:petualangansiagabumi/core/presentation/widgets/xp_popup.dart';
import 'package:petualangansiagabumi/core/presentation/widgets/confetti_widget.dart';

import '../result/game_over_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentIndex = 0;
  int? selectedIndex;
  bool answered = false;
  bool isLocked = false;

  int correctCount = 0;

  bool showXp = false;
  int xpGained = 0;

  final AudioPlayer player = AudioPlayer();

  List<Map<String, dynamic>> questions = [
    {
      "question": "Apa yang harus dilakukan saat gempa?",
      "options": [
        "Lari tanpa arah",
        "Berlindung di bawah meja",
        "Main HP",
        "Tidur"
      ],
      "answer": 1
    },
    {
      "question": "Saat banjir?",
      "options": [
        "Main air",
        "Naik ke tempat tinggi",
        "Tidur",
        "Berenang deras"
      ],
      "answer": 1
    },
    {
      "question": "Jika longsor?",
      "options": [
        "Mendekat",
        "Menjauh ke tempat aman",
        "Foto",
        "Diam"
      ],
      "answer": 1
    },
  ];

  @override
  void initState() {
    super.initState();
    questions.shuffle(Random());
    _preloadAudio();
  }

  Future<void> _preloadAudio() async {
    try {
      await player.setAsset('assets/sounds/click.mp3');
    } catch (_) {}
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
      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      debugPrint("AUDIO ERROR: $e");
    }
  }

  double get scorePercent {
    return (correctCount / questions.length) * 100;
  }

  void selectAnswer(int index) async {
    if (answered || isLocked) return;
    isLocked = true;

    await playSound("click.mp3");

    setState(() {
      selectedIndex = index;
      answered = true;
    });

    final correctIndex = questions[currentIndex]["answer"];
    final isCorrect = index == correctIndex;

    if (isCorrect) {
      correctCount++;
      await playSound("correct.mp3");

      ref.read(gameProvider.notifier).correctAnswer();

      setState(() {
        showXp = true;
        xpGained = 15;
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

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => showXp = false);
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          selectedIndex = null;
          answered = false;
        });
      } else {
        finishQuiz();
      }
      isLocked = false;
    });
  }

  void finishQuiz() async {
    final score = scorePercent;

    if (score >= 75) {
      await playSound("correct.mp3");
      ref.read(gameProvider.notifier).unlockNextLevel();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _successDialog(score),
      );
    } else {
      await playSound("wrong.mp3");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _retryDialog(score),
      );
    }
  }

  Widget _successDialog(double score) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("🎉 LULUS!", style: TextStyle(fontSize: 22)),
          const SizedBox(height: 10),
          Text("Nilai: ${score.toStringAsFixed(0)}%"),
          Text("Benar: $correctCount / ${questions.length}"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Kembali"),
          )
        ],
      ),
    );
  }

  Widget _retryDialog(double score) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("❌ Belum Lulus"),
          Text("Nilai: ${score.toStringAsFixed(0)}%"),
          Text("Benar: $correctCount / ${questions.length}"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentIndex = 0;
                selectedIndex = null;
                answered = false;
                correctCount = 0;
                questions.shuffle();
              });
            },
            child: const Text("Ulangi"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    final question = questions[currentIndex];
    final progress = (currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(title: const Text("Quiz")),

      body: Stack(
        children: [
          Column(
            children: [

              /// 🔥 HEADER GAME
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("❤️ ${game.hearts}"),
                        Text("⭐ ${game.xp} XP"),
                      ],
                    ),
                    const SizedBox(height: 8),

                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 6),

                    Text(
                      "Soal ${currentIndex + 1}/${questions.length} • Score ${scorePercent.toStringAsFixed(0)}%",
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ),

              /// 🧠 QUESTION CARD
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF1F5FF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ],
                  ),
                  child: Text(
                    question["question"],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              /// 🎯 OPTIONS
              Expanded(
                child: ListView.builder(
                  itemCount: question["options"].length,
                  itemBuilder: (context, i) {
                    final correctIndex = question["answer"];

                    bool isSelected = selectedIndex == i;
                    bool isCorrect = i == correctIndex;

                    Color bg = Colors.white;

                    if (answered) {
                      if (isCorrect) bg = Colors.green.shade200;
                      else if (isSelected) bg = Colors.red.shade200;
                    }

                    return GestureDetector(
                      onTap: () => selectAnswer(i),
                      child: AnimatedScale(
                        scale: isSelected ? 0.96 : 1,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12, blurRadius: 6)
                            ],
                          ),
                          child: Text(question["options"][i]),
                        ),
                      ),
                    );
                  },
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
}