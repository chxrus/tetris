class ScoreTracker {
  int score = 0;
  int lines = 0;
  int level = 1;

  static const List<int> _lineScores = [0, 100, 300, 500, 800];

  void applyClear(int cleared) {
    if (cleared <= 0) return;
    score += _lineScores[cleared] * level;
    lines += cleared;
    final newLevel = (lines ~/ 10) + 1;
    if (newLevel > level) level = newLevel;
  }
}
