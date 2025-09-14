import 'dart:math' as math;

import 'cell.dart';
import 'tetromino.dart';
import 'tetromino_type.dart';
import 'rotation/kicks.dart' as kicks;
import 'score_tracker.dart';
import 'seven_bag.dart';

class BoardModel {
  final int rows;
  final int cols;

  late final List<List<int>> cells;
  Tetromino? active;
  bool isGameOver = false;

  final SevenBag _sevenBag;

  List<int> _clearedRows = [];
  List<Cell> _lastLockedCells = [];

  final ScoreTracker _score = ScoreTracker();
  int get score => _score.score;
  int get lines => _score.lines;
  int get level => _score.level;

  TetrominoType get nextType => _sevenBag.nextType;

  TetrominoType? _lastLockType;
  TetrominoType? get lastLockType => _lastLockType;

  BoardModel({required this.rows, required this.cols, math.Random? random})
    : _sevenBag = SevenBag(random: random) {
    cells = List.generate(rows, (_) => List.filled(cols, 0));
    _spawnNew();
  }

  void _spawnNew() {
    final TetrominoType pieceType = _sevenBag.takeNext();

    final Tetromino tetromino = Tetromino.spawn(
      type: pieceType,
      originX: cols ~/ 2,
      originY: 0,
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

  bool _canPlace(Tetromino tetromino) {
    for (final Cell cell in tetromino.blocksAbsolute()) {
      if (!_emptyAt(cell.x, cell.y)) return false;
    }
    return true;
  }

  bool moveActive(int dx, int dy) {
    if (active == null) return false;
    final Tetromino candidate = active!.shift(dx, dy);
    if (_canPlace(candidate)) {
      active = candidate;
      return true;
    }
    return false;
  }

  bool canMoveActive(int dx, int dy) {
    if (active == null) return false;
    final Tetromino candidate = active!.shift(dx, dy);
    return _canPlace(candidate);
  }

  bool canMoveDown() => active != null && canMoveActive(0, 1);
  bool isGrounded() => active != null && !canMoveActive(0, 1);

  bool rotateActiveClockwise() => _rotateActive(1);
  bool rotateActiveCounterclockwise() => _rotateActive(-1);

  bool _rotateActive(int direction) {
    if (active == null) return false;

    final int from = active!.rotationIndex & 3;
    final int to = (from + (direction > 0 ? 1 : 3)) & 3;
    final Tetromino rotated = active!.copyWith(rotationIndex: to);

    for (final kicks.RotationOffset offset in kicks.srsKicks(
      active!.type,
      from,
      to,
    )) {
      final Tetromino candidate = rotated.shift(offset.dx, offset.dy);
      if (_canPlace(candidate)) {
        active = candidate;
        return true;
      }
    }
    return false;
  }

  bool fallOneCell() => active != null && moveActive(0, 1);

  void hardDropAndLock() {
    if (active == null) return;
    while (moveActive(0, 1)) {}
    _lockAtCurrentAndSpawn();
  }

  void lockAtCurrentPosition() => _lockAtCurrentAndSpawn();

  void _lockAtCurrentAndSpawn() {
    if (active == null) return;

    final List<Cell> placedCells = active!.blocksAbsolute();
    final TetrominoType type = active!.type;
    final int cellCode = type.index + 1;

    for (final Cell cell in placedCells) {
      if (_inside(cell.x, cell.y)) {
        cells[cell.y][cell.x] = cellCode;
      }
    }
    _lastLockType = type;

    final List<int> clearedRows = _clearFullLines();

    _clearedRows = clearedRows;
    _lastLockedCells = placedCells;
    _lastLockType = type;

    _score.applyClear(clearedRows.length);

    _spawnNew();
  }

  List<int> _clearFullLines() {
    final List<List<int>> rowsToKeep = <List<int>>[];
    final List<int> cleared = <int>[];

    for (int y = 0; y < rows; y++) {
      final bool isFull = cells[y].every((int cellValue) => cellValue != 0);
      if (isFull) {
        cleared.add(y);
      } else {
        rowsToKeep.add(cells[y]);
      }
    }

    for (int i = 0; i < cleared.length; i++) {
      rowsToKeep.insert(0, List.filled(cols, 0));
    }
    for (int y = 0; y < rows; y++) {
      cells[y] = rowsToKeep[y];
    }
    return cleared;
  }

  List<int> takeClearedRows() {
    final List<int> output = List<int>.from(_clearedRows);
    _clearedRows.clear();
    return output;
  }

  List<Cell> takeLastLockedCells() {
    final List<Cell> output = List<Cell>.from(_lastLockedCells);
    _lastLockedCells.clear();
    return output;
  }

  Duration fallPeriodForLevel(Duration baseFall) {
    const double decayPerLevel = 0.92;
    final double factor = math.pow(decayPerLevel, (level - 1)).toDouble();
    final int micros = (baseFall.inMicroseconds * factor).round();
    return Duration(microseconds: micros);
  }
}
