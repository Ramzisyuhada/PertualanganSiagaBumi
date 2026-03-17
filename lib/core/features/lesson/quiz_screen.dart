import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:petualangansiagabumi/core/features/home_map/map_screen.dart';

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

  int correctCount = 0;

  bool showXp = false;
  int xpGained = 0;

  final AudioPlayer player = AudioPlayer();

  /// 📚 DATA QUIZ
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
    questions.shuffle(Random()); // 🔥 ACAK
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  /// 🔊 AUDIO
  Future<void> playSound(String file) async {
    try {
      await player.stop();
      await player.setAsset('assets/sounds/$file');
      await player.play();
    } catch (e) {
      debugPrint("AUDIO ERROR: $e");
    }
  }

  /// 🎯 PILIH JAWABAN
  void selectAnswer(int index) async {
    if (answered) return;

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

    /// hide xp
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => showXp = false);
    });

    /// next
    Future.delayed(const Duration(milliseconds: 800), () {
      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          selectedIndex = null;
          answered = false;
        });
      } else {
        finishQuiz();
      }
    });
  }

  /// 🎯 FINISH QUIZ
  void finishQuiz() async {
    final score = (correctCount / questions.length) * 100;

    if (score >= 75) {
      await playSound("correct.mp3");

      /// 🔓 UNLOCK LEVEL
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

  /// 🏆 SUCCESS (SERTIFIKAT)
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
          const SizedBox(height: 20),

          /// 🎓 SERTIFIKAT
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "🏆 Sertifikat Digital\nSiswa Tangguh Bencana",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              /// 🔥 RESET NAVIGATION + REFRESH MAP
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
                (route) => false,
              );
            },
            child: const Text("Kembali ke Map"),
          )
        ],
      ),
    );
  }

  /// 🔁 RETRY
  Widget _retryDialog(double score) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("❌ Belum Lulus"),
          const SizedBox(height: 10),
          Text("Nilai: ${score.toStringAsFixed(0)}%"),
          const Text("Minimal 75%"),

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
      appBar: AppBar(
        title: const Text("POS 5 - Quiz"),
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
                        Text("❤️ ${game.hearts}"),
                        Text("⭐ ${game.xp} XP"),
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
                  question["question"],
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),

              /// OPTIONS
              Expanded(
                child: ListView.builder(
                  itemCount: question["options"].length,
                  itemBuilder: (context, i) {
                    final options = question["options"];
                    final correctIndex = question["answer"];

                    bool isSelected = selectedIndex == i;
                    bool isCorrect = i == correctIndex;

                    Color bg = Colors.white;
                    Color border = Colors.grey.shade300;

                    if (answered) {
                      if (isCorrect) {
                        bg = Colors.green.shade200;
                        border = Colors.green;
                      } else if (isSelected) {
                        bg = Colors.red.shade200;
                        border = Colors.red;
                      }
                    }

                    return GestureDetector(
                      onTap: () => selectAnswer(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border, width: 2),
                        ),
                        child: Text(options[i]),
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