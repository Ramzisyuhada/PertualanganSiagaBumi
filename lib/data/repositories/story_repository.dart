import '../models/story_model.dart';

class StoryRepository {
  final Map<String, StoryNode> story = {

    /// START
    "start": StoryNode(
      id: "start",
      scenario: "Terjadi gempa, kamu sedang di dalam rumah!",
      options: [
        StoryOption(
          text: "Berlindung di bawah meja",
          nextId: "safe",
          isCorrect: true,
        ),
        StoryOption(
          text: "Lari keluar panik",
          nextId: "injured",
          isCorrect: false,
        ),
      ],
    ),

    /// BENAR
    "safe": StoryNode(
      id: "safe",
      scenario: "Kamu selamat dari runtuhan!",
      feedback: "Pilihan yang tepat! 🎉",
      options: [
        StoryOption(
          text: "Keluar dengan hati-hati",
          nextId: "win",
          isCorrect: true,
        ),
      ],
    ),

    /// SALAH
    "injured": StoryNode(
      id: "injured",
      scenario: "Kamu terkena puing!",
      feedback: "Kamu terluka! ❌",
      options: [
        StoryOption(
          text: "Mencari bantuan",
          nextId: "win",
          isCorrect: false,
        ),
      ],
    ),

    /// ENDING
    "win": StoryNode(
      id: "win",
      scenario: "Kamu berhasil selamat! 🏆",
      feedback: "Misi selesai!",
      options: [],
    ),
  };

  StoryNode getNode(String id) => story[id]!;
}