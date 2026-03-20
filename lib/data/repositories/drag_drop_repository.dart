import '../models/drag_drop_model.dart';

class DragDropRepository {

  final List<DragDropModel> _questions = [

    /// ========================
    /// PART 1 (PENYEBAB)
    /// ========================
    DragDropModel(
      question: "Pasangkan penyebab dengan bencana yang tepat",
      options: ["Hujan sangat deras", "Tanah tanpa pohon", "Pergerakan bumi"],
      answers: {
        "Hujan sangat deras": "Banjir",
        "Tanah tanpa pohon": "Longsor",
        "Pergerakan bumi": "Gempa",
      },
    ),

    DragDropModel(
      question: "Mana penyebab bencana berikut?",
      options: ["Saluran air tersumbat", "Hutan ditebang", "Bumi bergeser"],
      answers: {
        "Saluran air tersumbat": "Banjir",
        "Hutan ditebang": "Longsor",
        "Bumi bergeser": "Gempa",
      },
    ),

    DragDropModel(
      question: "Cocokkan kondisi yang menyebabkan bencana",
      options: ["Air sungai meluap", "Tanah mudah runtuh", "Tekanan dalam bumi"],
      answers: {
        "Air sungai meluap": "Banjir",
        "Tanah mudah runtuh": "Longsor",
        "Tekanan dalam bumi": "Gempa",
      },
    ),

    /// ========================
    /// PART 2 (DAMPAK)
    /// ========================
    DragDropModel(
      question: "Pasangkan dampak dengan bencana",
      options: ["Rumah terendam air", "Jalan tertutup tanah", "Bangunan retak"],
      answers: {
        "Rumah terendam air": "Banjir",
        "Jalan tertutup tanah": "Longsor",
        "Bangunan retak": "Gempa",
      },
    ),

    DragDropModel(
      question: "Apa akibat dari bencana berikut?",
      options: ["Air meluap ke rumah", "Tanah turun dari bukit", "Tanah bergetar"],
      answers: {
        "Air meluap ke rumah": "Banjir",
        "Tanah turun dari bukit": "Longsor",
        "Tanah bergetar": "Gempa",
      },
    ),

    DragDropModel(
      question: "Cocokkan situasi yang terjadi saat bencana",
      options: ["Banyak genangan air", "Lereng jatuh", "Tanah bergoyang"],
      answers: {
        "Banyak genangan air": "Banjir",
        "Lereng jatuh": "Longsor",
        "Tanah bergoyang": "Gempa",
      },
    ),
  ];

  /// 🔥 RANDOM + AMBIL SEMUA
  List<DragDropModel> getQuestions() {
    final list = List<DragDropModel>.from(_questions);
    list.shuffle();
    return list;
  }

  /// 🔥 PART SYSTEM
 List<DragDropModel> getQuestionsByPart(int part) {
  final list = getQuestions();

  List<DragDropModel> selected;

  if (part == 1) {
    selected = list.take(3).toList();
  } else {
    selected = list.skip(3).take(3).toList();
  }

  /// 🔥 ACAK OPTION DI SETIAP SOAL
  return selected.map((q) {
    final shuffledOptions = List<String>.from(q.options);
    shuffledOptions.shuffle();

    return DragDropModel(
      question: q.question,
      options: shuffledOptions,
      answers: q.answers,
    );
  }).toList();
}
}