import '../models/drag_drop_model.dart';

class DragDropRepository {
  List<DragDropModel> getQuestions() {
    return [
      DragDropModel(
        question: "Cocokkan penyebab dengan bencana",
        options: ["Hujan Deras", "Tanah Gundul", "Lempeng Bumi"],
        answers: {
          "Hujan Deras": "Banjir",
          "Tanah Gundul": "Longsor",
          "Lempeng Bumi": "Gempa",
        },
      ),
    ];
  }
}