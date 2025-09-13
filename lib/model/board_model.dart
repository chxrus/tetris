import 'dart:math';

import 'package:tetris/model/tetromino.dart';

class BoardModel {
  final int rows;
  final int cols;

  late final List<List<int>> cells;

  final _rng = Random();
  Tetromino? active;
  bool isGameOver = false;

  BoardModel({required this.rows, required this.cols}) {
    cells = List.generate(rows, (_) => List.filled(cols, 0));
    _spawnNew();
  }

  void _spawnNew() {
    final type = TetrominoType.values[_rng.nextInt(TetrominoType.values.length)];
    final tetromino = Tetromino(type: type, originX: cols ~/ 2, originY: 0);
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
    final t = Tetromino(
      type: active!.type,
      originX: active!.originX + dx,
      originY: active!.originY + dy,
      rotationIndex: active!.rotationIndex,
    );
    if (_canPlace(t)) {
      active = t;
      return true;
    }
    return false;
  }

  bool isGrounded() => active != null && !canMoveActive(0, 1);
  bool rotateActiveClockwise()  => _rotateActive(1);
  bool rotateActiveCounterclockwise() => _rotateActive(-1);

  bool _rotateActive(int dir) {
    if (active == null) return false;
    final nextRotation = (active!.rotationIndex + (dir > 0 ? 1 : 3)) & 3;

    // простые "кики" у стены — пробуем сдвинуться по X
    const kicks = [0, 1, -1, 2, -2];
    for (final dx in kicks) {
      final t = Tetromino(
        type: active!.type,
        originX: active!.originX + dx,
        originY: active!.originY,
        rotationIndex: nextRotation,
      );
      if (_canPlace(t)) {
        active = t;
        return true;
      }
    }
    return false;
  }

bool canMoveActive(int dx, int dy) {
  if (active == null) return false;
  final t = Tetromino(
    type: active!.type,
    originX: active!.originX + dx,
    originY: active!.originY + dy,
    rotationIndex: active!.rotationIndex,
  );
  return _canPlace(t);
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
    for (final c in active!.blocksAbsolute()) {
      if (_inside(c.x, c.y)) cells[c.y][c.x] = 1;
    }
    _clearFullLines();
    _spawnNew();
  }

  void _clearFullLines() {
    final newRows = <List<int>>[];
    int cleared = 0;
    for (var y = 0; y < rows; y++) {
      final full = cells[y].every((v) => v != 0);
      if (full) {
        cleared++;
      } else {
        newRows.add(cells[y]);
      }
    }
    for (var i = 0; i < cleared; i++) {
      newRows.insert(0, List.filled(cols, 0));
    }
    for (var y = 0; y < rows; y++) {
      cells[y] = newRows[y];
    }
  }
}
