import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petualangansiagabumi/data/repositories/decision_repository.dart';
import 'package:petualangansiagabumi/data/repositories/drag_drop_repository.dart';
import 'package:petualangansiagabumi/data/repositories/matching_repository.dart';
import 'package:petualangansiagabumi/data/repositories/story_repository.dart';
import '../../data/repositories/lesson_repository.dart';

final lessonProvider = Provider((ref) => LessonRepository());
final dragDropProvider = Provider((ref) {
  return DragDropRepository();
});
final matchingProvider = Provider((ref) => MatchingRepository());
final decisionProvider = Provider((ref) => DecisionRepository());
final storyProvider = Provider((ref) => StoryRepository());