import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';

import 'package:petualangansiagabumi/core/features/lesson/about_screen.dart';
import 'package:petualangansiagabumi/core/features/lesson/decision_screen.dart';
import 'package:petualangansiagabumi/core/presentation/widgets/level_bubble.dart';
import 'package:petualangansiagabumi/core/presentation/widgets/map_path_painter.dart';
import 'package:petualangansiagabumi/core/utils/game_provider.dart';

import '../lesson/lesson_screen.dart';
import '../lesson/drag_drop_screen.dart';
import '../lesson/matching_screen.dart';
import '../quiz/quiz_screen.dart';

/// =======================
/// MODEL
/// =======================
class LevelModel {
  final String title;
  final Widget screen;

  LevelModel({
    required this.title,
    required this.screen,
  });
}

/// =======================
/// MAP SCREEN
/// =======================
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  final AudioPlayer clickPlayer = AudioPlayer();

  bool isNavigating = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    /// 🔥 PRELOAD AUDIO (ANTI LAG)
    clickPlayer.setAsset('assets/sounds/click.mp3');
  }

  @override
  void dispose() {
    clickPlayer.dispose();
    controller.dispose();
    super.dispose();
  }

  /// 🔊 AUDIO SMOOTH
  Future<void> playClick() async {
    try {
      clickPlayer.stop();
      await clickPlayer.seek(Duration.zero);
      clickPlayer.play();
    } catch (_) {}
  }

  /// 🎬 NAVIGATION ANIMATION
  void goToScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.0)
                  .animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// 📍 POSITION
  Offset getPosition(int index, double width) {
    double spacing = 160;

    final x = (index % 2 == 0) ? 70.0 : width - 70;
    final y = index * spacing + 80;

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);

    final levels = [
      LevelModel(title: "POS 1", screen: const LessonScreen()),
      LevelModel(title: "POS 2", screen: const DragDropScreen()),
      LevelModel(title: "POS 3", screen: const MatchingScreen()),
      LevelModel(title: "POS 4", screen: const DecisionScreen()),
      LevelModel(title: "POS 5", screen: QuizScreen()),
    ];

    final avatarPos = getPosition(
      (game.level - 1).clamp(0, levels.length - 1),
      MediaQuery.of(context).size.width,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _badge("❤️ ${game.hearts}", Colors.red),
                  _badge("⭐ ${game.xp}", Colors.orange),
                  _badge("🏆 Lv ${game.level}", Colors.green),

                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            /// MAP
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return Stack(
                    children: [

                      const MapBackground(),

                      Positioned.fill(
                        child: CustomPaint(
                          painter: MapPathPainter(
                            total: levels.length,
                            animationValue: controller.value,
                          ),
                        ),
                      ),

                      /// LEVEL LIST
                      ListView.builder(
                        itemCount: levels.length,
                        itemBuilder: (context, index) {
                          final isLeft = index % 2 == 0;
                          final unlocked = index < game.level;
                          return Padding(
                            padding: EdgeInsets.only(
                              top: index == 0 ? 20 : 60,
                              left: isLeft ? 20 : 0,
                              right: isLeft ? 0 : 20,
                            ),
                            child: Align(
                              alignment: isLeft
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: LevelBubble(
                                title: levels[index].title,
                                unlocked: unlocked,
                                onTap: () async {
                                  if (!unlocked || isNavigating) return;

                                  isNavigating = true;

                                  await playClick();

                                  await Future.delayed(
                                      const Duration(milliseconds: 120));

                                  goToScreen(levels[index].screen);

                                  isNavigating = false;
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      /// AVATAR
                      _Avatar(position: avatarPos),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// =======================
/// AVATAR
/// =======================
class _Avatar extends StatelessWidget {
  final Offset position;

  const _Avatar({required this.position});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 20,
      top: position.dy - 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.orange,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ).animate().scale(duration: 300.ms),
    );
  }
}

/// =======================
/// BACKGROUND
/// =======================
class MapBackground extends StatefulWidget {
  const MapBackground({super.key});

  @override
  State<MapBackground> createState() => _MapBackgroundState();
}

class _MapBackgroundState extends State<MapBackground> {
  double cloudOffset = 0;

  @override
  void initState() {
    super.initState();

    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return false;

      setState(() {
        cloudOffset += 1;
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Stack(
      children: [

        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFB3E5FC),
                Color(0xFFE1F5FE),
              ],
            ),
          ),
        ),

        Positioned(
          top: 80,
          left: cloudOffset % width,
          child: _cloud(),
        ),

        Positioned(
          top: 150,
          left: (cloudOffset + 150) % width,
          child: _cloud(),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: const Size(double.infinity, 200),
            painter: MountainPainter(),
          ),
        ),
      ],
    );
  }

  Widget _cloud() {
    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}

/// =======================
/// MOUNTAIN
/// =======================
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green.shade400;

    final path = Path();

    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}