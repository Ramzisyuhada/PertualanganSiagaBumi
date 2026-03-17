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

  bool showXp = false;
  int xp = 0;

  void chooseOption(String text, String nextId, bool isCorrect) {
    if (isAnswered) return;

    setState(() {
      selected = text;
      isAnswered = true;
    });

    if (isCorrect) {
      ref.read(gameProvider.notifier).correctAnswer();

      setState(() {
        showXp = true;
        xp = 20;
      });
    } else {
      ref.read(gameProvider.notifier).wrongAnswer();
    }

    /// delay → next node
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        currentId = nextId;
        isAnswered = false;
        selected = null;
      });
    });

    /// hide XP
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => showXp = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final story = ref.watch(storyProvider);
    final node = story.getNode(currentId);

    final game = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(title: const Text("Story Mode")),

      body: Stack(
        children: [
          Column(
            children: [

              /// HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("❤️ ${game.hearts}"),
                    Text("⭐ ${game.xp} XP"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// SCENARIO
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  node.scenario,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// FEEDBACK
              if (isAnswered && node.feedback != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    node.feedback!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              /// OPTIONS
              Expanded(
                child: ListView(
                  children: node.options.map((opt) {
                    final isSelected = selected == opt.text;

                    return GestureDetector(
                      onTap: () =>
                          chooseOption(opt.text, opt.nextId, opt.isCorrect),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade100
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(opt.text),
                      ),
                    );
                  }).toList(),
                ),
              ),

              /// END BUTTON
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
}