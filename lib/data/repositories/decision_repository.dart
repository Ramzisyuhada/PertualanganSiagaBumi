import '../models/decision_model.dart';

class DecisionRepository {
  List<DecisionModel> getQuestions() {
    return [
      DecisionModel(
        scenario: "Terjadi gempa, apa yang harus kamu lakukan?",
        options: [
          "Lari keluar",
          "Berlindung di bawah meja",
          "Berdiri dekat kaca"
        ],
        correct: "Berlindung di bawah meja",
      ),
      DecisionModel(
        scenario: "Terjadi banjir, apa yang harus dilakukan?",
        options: [
          "Tetap di rumah",
          "Naik ke tempat tinggi",
          "Main air"
        ],
        correct: "Naik ke tempat tinggi",
      ),
    ];
  }
}