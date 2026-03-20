import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';

import 'package:petualangansiagabumi/core/presentation/widgets/lesson_card.dart';
import 'package:petualangansiagabumi/core/utils/game_provider.dart';
import 'drag_drop_screen.dart';

import 'ppt_screen.dart';
import 'video_screen.dart';
import 'package:petualangansiagabumi/core/presentation/widgets/xp_popup.dart';

/// 🔥 DATA DI LUAR (ANTI REBUILD)
final List<Map<String, dynamic>> lessons = [
  {
    "title": "Apa itu Bencana?",
    "icon": Icons.warning,
    "content": "Bencana adalah kejadian yang berbahaya bagi manusia dan lingkungan."
  },
  {
    "title": "Jenis Bencana",
    "icon": Icons.public,
    "content": "Ada beberapa jenis bencana seperti banjir, gempa, longsor."
  },
  {
    "title": "Mitigasi",
    "icon": Icons.shield,
    "content": "Mitigasi adalah cara mengurangi dampak bencana."
  },
  {
    "title": "Evakuasi",
    "icon": Icons.directions_run,
    "content": "Evakuasi adalah cara menyelamatkan diri saat bencana."
  },
];

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  String? animatingCard;
  bool showXp = false;
  int xpValue = 0;

  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    /// 🔥 PRELOAD AUDIO (WAJIB)
    player.setAsset('assets/sounds/click.mp3');
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  /// 🔊 AUDIO ANTI LAG
  Future<void> playSound(String file) async {
    try {
      player.stop();
      await player.seek(Duration.zero);
      player.play();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    final progress = (game.openedCards.length / lessons.length)
        .clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("POS 1 - Pembelajaran"),
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
                    final opened =
                        game.openedCards.contains(title);

                    return KeyedSubtree(
                      key: ValueKey(title), // 🔥 anti rebuild berat
                      child: LessonCard(
                        title: title,
                        icon: item["icon"] as IconData,
                        opened: opened,
                        isAnimating: animatingCard == title,
                        onTap: () async {
                          if (animatingCard != null) return;

                          await playSound("click.mp3");

                          if (opened) {
                            _showDetail(context, item);
                            return;
                          }

                          setState(() {
                            animatingCard = title;
                            showXp = true;
                            xpValue = 5;
                          });

                          ref
                              .read(gameProvider.notifier)
                              .openCard(title);

                          await playSound("correct.mp3");

                          /// 🔥 SINGLE FLOW (NO BUG)
                          Future.delayed(
                              const Duration(milliseconds: 700), () {
                            if (!mounted) return;

                            setState(() {
                              showXp = false;
                              animatingCard = null;
                            });

                            _showDetail(context, item);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              /// PPT + VIDEO BUTTON
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _menuButton(
                      color1: Colors.deepPurple,
                      color2: Colors.deepPurpleAccent,
                      icon: Icons.slideshow,
                      label: "PPT",
                      onTap: () async {
                        await playSound("click.mp3");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PPTScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _menuButton(
                      color1: Colors.red,
                      color2: Colors.redAccent,
                      icon: Icons.play_circle_fill,
                      label: "Video",
                      onTap: () async {
                        await playSound("click.mp3");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VideoScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              /// NEXT BUTTON
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: game.openedCards.length == lessons.length
                      ? () async {
                          await playSound("click.mp3");
                          ref
                              .read(gameProvider.notifier)
                              .unlockNextLevel();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DragDropScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Lanjut ke POS 2"),
                ),
              ),
            ],
          ),

          /// XP POPUP (RINGAN)
          if (showXp) XpPopup(xp: xpValue),
        ],
      ),
    );
  }

  /// DETAIL
  void _showDetail(BuildContext context, Map item) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (_) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item["content"],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
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
            color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _menuButton({
    required Color color1,
    required Color color2,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1, color2],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color1.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
            .animate()
            .scale(duration: 150.ms)
            .fadeIn(),
      ),
    );
  }
}