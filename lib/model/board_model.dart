import 'dart:math' as math;
import 'package:tetris/model/tetromino.dart';
import 'package:tetris/model/rotation/kicks.dart' as kicks;

class BoardModel {
  final int rows;
  final int cols;

  int score = 0;
  int lines = 0;
  int level = 1;

  late final List<List<int>> cells;

  List<int> _clearedRows = [];
  List<Cell> _lastLockedCells = [];
  int _lastLockColor = 0;

  // очки за 1-4 линии (Guideline * множитель уровня)
  static const List<int> _lineScores = [0, 100, 300, 500, 800];

  static const Map<TetrominoType, int> _typeColor = {
    TetrominoType.I: 0xFF00BCD4, // cyan
    TetrominoType.J: 0xFF1E88E5, // blue
    TetrominoType.L: 0xFFF57C00, // orange
    TetrominoType.O: 0xFFFBC02D, // yellow
    TetrominoType.S: 0xFF43A047, // green
    TetrominoType.T: 0xFF8E24AA, // purple
    TetrominoType.Z: 0xFFE53935, // red
  };

  List<TetrominoType> _bag = [];

  void _refillBag() {
    _bag = TetrominoType.values.toList()..shuffle(_rng);
  }

  TetrominoType _drawFromBag() {
    if (_bag.isEmpty) _refillBag();
    return _bag.removeAt(0);
  }

  final _rng = math.Random();
  Tetromino? active;
  bool isGameOver = false;

  BoardModel({required this.rows, required this.cols}) {
    cells = List.generate(rows, (_) => List.filled(cols, 0));
    _spawnNew();
  }

  void _spawnNew() {
    final type = _drawFromBag();
    final colorValue = _typeColor[type]!;
    final tetromino = Tetromino(
      type: type,
      originX: cols ~/ 2,
      originY: 0,
      rotationIndex: 0,
      colorValue: colorValue,
    );
    if (_canPlace(tetromino)) {
      active = tetromino;
    } else {
      isGameOver = true;
      active = null;
    }
  }

  bool _inside(int x, int y) => x >= 0 && x < cols && y >= 0 && y < rows;
  bool _emptyAt(int x, int y) => _inside(x, y) && cells[y][x] == 0;

  bool _canPlace(Tetromino t) {
    for (final cell in t.blocksAbsolute()) {
      if (!_emptyAt(cell.x, cell.y)) return false;
    }
    return true;
  }

  bool moveActive(int dx, int dy) {
    if (active == null) return false;
    final candidate = active!.shift(dx, dy);
    if (_canPlace(candidate)) {
      active = candidate;
      return true;
    }
    return false;
  }

  bool isGrounded() => active != null && !canMoveActive(0, 1);
  bool rotateActiveClockwise() => _rotateActive(1);
  bool rotateActiveCounterclockwise() => _rotateActive(-1);

  bool _rotateActive(int dir) {
    if (active == null) return false;

    final from = active!.rotationIndex & 3;
    final to = (from + (dir > 0 ? 1 : 3)) & 3;
    final rotated = active!.copyWith(rotationIndex: to);

    for (final off in kicks.srsKicks(active!.type, from, to)) {
      final candidate = rotated.shift(off.dx, off.dy);
      if (_canPlace(candidate)) {
        active = candidate;
        return true;
      }
    }
    return false;
  }

  bool canMoveActive(int dx, int dy) {
    if (active == null) return false;
    final candidate = active!.shift(dx, dy);
    return _canPlace(candidate);
  }

  bool canMoveDown() => active != null && canMoveActive(0, 1);
  bool fallOneCell() => active != null && moveActive(0, 1);

  void hardDropAndLock() {
    if (active == null) return;
    while (moveActive(0, 1)) {}
    _lockAtCurrentAndSpawn();
  }

  void lockAtCurrentPosition() => _lockAtCurrentAndSpawn();

  void _lockAtCurrentAndSpawn() {
    if (active == null) return;
    final placed = active!.blocksAbsolute();
    final color = active!.colorValue;

    for (final c in placed) {
      if (_inside(c.x, c.y)) cells[c.y][c.x] = color;
    }

    final clearedRows = _clearFullLines();
    _clearedRows = clearedRows;

    _lastLockedCells = placed;
    _lastLockColor = color;

    _applyScoring(clearedRows.length);
    _spawnNew();
  }

  List<int> _clearFullLines() {
    final rowsToKeep = <List<int>>[];
    final cleared = <int>[];

    for (var y = 0; y < rows; y++) {
      final full = cells[y].every((v) => v != 0);
      if (full) {
        cleared.add(y);
      } else {
        rowsToKeep.add(cells[y]);
      }
    }

    for (var i = 0; i < cleared.length; i++) {
      rowsToKeep.insert(0, List.filled(cols, 0));
    }
    for (var y = 0; y < rows; y++) {
      cells[y] = rowsToKeep[y];
    }
    return cleared;
  }

  void _applyScoring(int cleared) {
    if (cleared <= 0) return;
    score += _lineScores[cleared] * level;
    lines += cleared;
    final newLevel = (lines ~/ 10) + 1;
    if (newLevel > level) {
      level = newLevel;
    }
  }

  Duration fallPeriodForLevel(Duration baseFall) {
    const decayPerLevel = 0.92;
    final factor = math.pow(decayPerLevel, (level - 1)).toDouble();
    final micros = (baseFall.inMicroseconds * factor).round();
    return Duration(microseconds: micros);
  }

  List<int> takeClearedRows() {
    final out = List<int>.from(_clearedRows);
    _clearedRows.clear();
    return out;
  }

  List<Cell> takeLastLockedCells() {
    final out = List<Cell>.from(_lastLockedCells);
    _lastLockedCells.clear();
    return out;
  }

  int get lastLockColor => _lastLockColor;
}
