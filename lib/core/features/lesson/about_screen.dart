import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      body: Column(
        children: [

          /// 🌈 HERO HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4CAF50),
                  Color(0xFF81C784),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [

                /// BACK BUTTON
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 10),

                /// ICON
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.public, size: 40, color: Colors.green),
                ).animate().scale(duration: 400.ms),

                const SizedBox(height: 10),

                /// TITLE
                const Text(
                  "Petualang Siaga Bumi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Text(
                  "Edukasi Mitigasi Bencana",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 10),

                /// VERSION
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Versi 1.0",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),

          /// 📜 CONTENT
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                _featureCard(
                  icon: Icons.lightbulb,
                  title: "Konsep Aplikasi",
                  content:
                      "Aplikasi ini menggunakan pendekatan gamifikasi untuk membantu siswa belajar mitigasi bencana secara interaktif dan menyenangkan.",
                  color: Colors.orange,
                ),

                _featureCard(
                  icon: Icons.flag,
                  title: "Tujuan",
                  content:
                      "Meningkatkan kesadaran siswa terhadap bencana dan membangun kesiapsiagaan melalui simulasi dan permainan edukatif.",
                  color: Colors.blue,
                ),

                _featureCard(
                  icon: Icons.videogame_asset,
                  title: "Fitur Utama",
                  content:
                      "• Lesson Interaktif\n"
                      "• Drag & Drop\n"
                      "• Matching Game\n"
                      "• Story Decision\n"
                      "• Quiz + Sertifikat",
                  color: Colors.green,
                ),

                _featureCard(
                  icon: Icons.person,
                  title: "Developer",
                  content:
                      "Ramzi Syuhada\nFlutter Developer\nVR/AR Enthusiast",
                  color: Colors.purple,
                ),

                const SizedBox(height: 10),

                /// FOOTER
                Center(
                  child: Text(
                    "© 2025 Edukasi Bencana Indonesia",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// 🔥 FEATURE CARD MODERN
  Widget _featureCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(content),
              ],
            ),
          )
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }
}