import '../models/lesson_model.dart';

class LessonRepository {
  List<LessonModel> getLessons() {
    return [
      LessonModel(
        title: "Gempa",
        image: "assets/gempa.png",
        description: "Gempa adalah getaran bumi",
      ),
      LessonModel(
        title: "Banjir",
        image: "assets/banjir.png",
        description: "Banjir terjadi karena air meluap",
      ),
    ];
  }
}