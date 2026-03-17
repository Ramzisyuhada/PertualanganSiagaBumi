class StoryOption {
  final String text;
  final String nextId;
  final bool isCorrect;

  StoryOption({
    required this.text,
    required this.nextId,
    required this.isCorrect,
  });
}

class StoryNode {
  final String id;
  final String scenario;
  final String? feedback;
  final List<StoryOption> options;

  StoryNode({
    required this.id,
    required this.scenario,
    this.feedback,
    required this.options,
  });
}