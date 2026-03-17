import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';

import 'package:petualangansiagabumi/core/presentation/widgets/lesson_card.dart';
import 'package:petualangansiagabumi/core/utils/game_provider.dart';
import 'drag_drop_screen.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  String? animatingCard;
  bool showXp = false;
  int xpValue = 0;

  /// 🔊 AUDIO PLAYER
  final AudioPlayer player = AudioPlayer();

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  /// 🔊 PLAY SOUND
  Future<void> playSound(String file) async {
    try {
      await player.stop();
      await player.setAsset('assets/sounds/$file');
      await player.play();
    } catch (e) {
      debugPrint("AUDIO ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    final lessons = [
      {"title": "Apa itu Bencana?", "icon": Icons.warning},
      {"title": "Jenis Bencana", "icon": Icons.public},
      {"title": "Mitigasi", "icon": Icons.shield},
      {"title": "Evakuasi", "icon": Icons.directions_run},
    ];

    final progress = game.openedCards.length / lessons.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("POS 1 - Pembelajaran"),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text("${game.openedCards.length}/${lessons.length} selesai"),
                  ],
                ),
              ),

              /// LIST LESSON
              Expanded(
                child: ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final item = lessons[index];
                    final title = item["title"].toString();
                    final opened = game.openedCards.contains(title);

                    return LessonCard(
                      title: title,
                      icon: item["icon"] as IconData,
                      opened: opened,
                      isAnimating: animatingCard == title,
                      onTap: () async {

                        /// 🔊 CLICK SOUND
                        await playSound("click.mp3");

                        final alreadyOpened = opened;

                        if (alreadyOpened) {
                          _showDetail(context, title);
                          return;
                        }

                        /// 🔥 XP + SOUND
                        setState(() {
                          animatingCard = title;
                          showXp = true;
                          xpValue = 5;
                        });

                        ref.read(gameProvider.notifier).openCard(title);

                        /// 🔊 REWARD SOUND
                        await playSound("correct.mp3");

                        /// hide XP
                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) {
                            setState(() {
                              showXp = false;
                              animatingCard = null;
                            });
                          }
                        });

                        /// buka detail
                        Future.delayed(const Duration(milliseconds: 300), () {
                          _showDetail(context, title);
                        });
                      },
                    );
                  },
                ),
              ),

              /// NEXT BUTTON
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: game.openedCards.length == lessons.length
                      ? () async {

                          /// 🔊 CLICK NEXT
                          await playSound("click.mp3");
                          ref.read(gameProvider.notifier).unlockNextLevel();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DragDropScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Lanjut ke POS 2"),
                ),
              ),
            ],
          ),

          /// XP POPUP
          if (showXp)
            Center(
              child: Text(
                "+$xpValue XP",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              )
                  .animate()
                  .scale(duration: 300.ms)
                  .fadeIn()
                  .then()
                  .moveY(begin: 0, end: -80, duration: 800.ms)
                  .fadeOut(),
            ),
        ],
      ),
    );
  }

  /// DETAIL
  void _showDetail(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "$title\n\nPenjelasan materi di sini...",
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
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