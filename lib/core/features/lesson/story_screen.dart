import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petualangansiagabumi/core/utils/providers.dart';
import 'package:petualangansiagabumi/core/utils/game_provider.dart';

import 'package:petualangansiagabumi/core/presentation/widgets/xp_popup.dart';
import 'package:petualangansiagabumi/core/presentation/widgets/confetti_widget.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  String currentId = "start";

  bool isAnswered = false;
  String? selected;
  bool? isCorrectAnswer;

  bool showXp = false;
  int xp = 0;

  int step = 0;
  final int totalStep = 5;

  void chooseOption(String text, String nextId, bool isCorrect) {
    if (isAnswered) return;

    setState(() {
      selected = text;
      isAnswered = true;
      isCorrectAnswer = isCorrect;
    });

    if (isCorrect) {
      ref.read(gameProvider.notifier).correctAnswer();
      showXp = true;
      xp = 20;
    } else {
      ref.read(gameProvider.notifier).wrongAnswer();
    }

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      setState(() {
        currentId = nextId;
        isAnswered = false;
        selected = null;
        isCorrectAnswer = null;

        if (step < totalStep) step++;
        showXp = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final story = ref.watch(storyProvider);
    final node = story.getNode(currentId);
    final game = ref.watch(gameProvider);

    final progress = (step / totalStep).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("Story Mode"),
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
                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.green),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// SCENARIO (CARD STYLE)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      node.scenario,
                      key: ValueKey(node.scenario),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// FEEDBACK
              if (isAnswered && node.feedback != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        isCorrectAnswer == true
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: isCorrectAnswer == true
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          node.feedback!,
                          style: TextStyle(
                            fontSize: 16,
                            color: isCorrectAnswer == true
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              /// OPTIONS
              Expanded(
                child: ListView.builder(
                  itemCount: node.options.length,
                  itemBuilder: (context, index) {
                    final opt = node.options[index];

                    final isSelected = selected == opt.text;

                    return _OptionButton(
                      text: opt.text,
                      isSelected: isSelected,
                      isAnswered: isAnswered,
                      isCorrect: opt.isCorrect,
                      onTap: isAnswered
                          ? null
                          : () => chooseOption(
                                opt.text,
                                opt.nextId,
                                opt.isCorrect,
                              ),
                    );
                  },
                ),
              ),

              /// END
              if (node.options.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Selesai"),
                  ),
                ),
            ],
          ),

          if (showXp) XpPopup(xp: xp),
          if (showXp) const ConfettiWidgetCustom(),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// 🔥 OPTION BUTTON (DUOLINGO STYLE)
class _OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isAnswered;
  final bool isCorrect;
  final VoidCallback? onTap;

  const _OptionButton({
    required this.text,
    required this.isSelected,
    required this.isAnswered,
    required this.isCorrect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;

    if (isAnswered && isSelected) {
      if (isCorrect) {
        bgColor = Colors.green.shade100;
        borderColor = Colors.green;
      } else {
        bgColor = Colors.red.shade100;
        borderColor = Colors.red;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (isAnswered && isSelected)
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
          ],
        ),
      ),
    );
  }
}