class DecisionQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  DecisionQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class DecisionSection {
  final String title;
  final List<DecisionQuestion> questions;

  DecisionSection({
    required this.title,
    required this.questions,
  });
}

final decisionData = [
  DecisionSection(
    title: "A. GEMPA BUMI",
    questions: [
      DecisionQuestion(
        question: "Saat gempa terjadi di kelas, apa yang harus kamu lakukan?",
        options: [
          "Panik berlari keluar kelas",
          "Berlindung di bawah meja yang kuat",
          "Berteriak memanggil teman"
        ],
        correctIndex: 1,
      ),
      DecisionQuestion(
        question: "Setelah gempa berhenti, apa yang dilakukan?",
        options: [
          "Keluar dengan tertib mengikuti arahan guru",
          "Kembali duduk dan bermain",
          "Lari saling dorong"
        ],
        correctIndex: 0,
      ),
    ],
  ),

  DecisionSection(
    title: "B. BANJIR",
    questions: [
      DecisionQuestion(
        question: "Air mulai masuk ke rumah, apa yang dilakukan?",
        options: [
          "Bermain air",
          "Naik ke tempat tinggi",
          "Mengambil perahu mainan"
        ],
        correctIndex: 1,
      ),
      DecisionQuestion(
        question: "Saat banjir kamu tidak boleh...",
        options: [
          "Mendengarkan orang tua",
          "Mendekati arus deras",
          "Membawa barang penting"
        ],
        correctIndex: 1,
      ),
    ],
  ),

  DecisionSection(
    title: "C. TANAH LONGSOR",
    questions: [
      DecisionQuestion(
        question: "Jika tinggal di lereng dan hujan deras...",
        options: [
          "Tetap bermain",
          "Waspada dan bersiap mengungsi",
          "Tidur saja"
        ],
        correctIndex: 1,
      ),
      DecisionQuestion(
        question: "Saat longsor terjadi...",
        options: [
          "Mendekat untuk melihat",
          "Menjauh ke tempat aman",
          "Mengambil foto"
        ],
        correctIndex: 1,
      ),
    ],
  ),

  DecisionSection(
    title: "D. GUNUNG MELETUS",
    questions: [
      DecisionQuestion(
        question: "Saat gunung meletus, gunakan...",
        options: [
          "Masker atau kain",
          "Topi ulang tahun",
          "Kacamata renang"
        ],
        correctIndex: 0,
      ),
      DecisionQuestion(
        question: "Saat evakuasi...",
        options: [
          "Ikuti petugas",
          "Menunggu teman",
          "Bermain dulu"
        ],
        correctIndex: 0,
      ),
    ],
  ),
];