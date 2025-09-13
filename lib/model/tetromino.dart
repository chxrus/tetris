class Cell {
  final int x, y;
  const Cell(this.x, this.y);
}

enum TetrominoType { I, O, T, J, L, S, Z }

class Tetromino {
  final TetrominoType type;
  final int rotationIndex; // 0..3
  final int originX;
  final int originY;
  final int colorValue;

  const Tetromino({
    required this.type,
    required this.originX,
    required this.originY,
    this.rotationIndex = 0,
    required this.colorValue,
  });

  Tetromino copyWith({int? originX, int? originY, int? rotationIndex}) {
    return Tetromino(
      type: type,
      originX: originX ?? this.originX,
      originY: originY ?? this.originY,
      rotationIndex: rotationIndex ?? this.rotationIndex,
      colorValue: colorValue,
    );
  }

  static const Map<TetrominoType, List<List<Cell>>> _shapes = {
    TetrominoType.O: [
      [Cell(0, 0), Cell(1, 0), Cell(0, 1), Cell(1, 1)],
      [Cell(0, 0), Cell(1, 0), Cell(0, 1), Cell(1, 1)],
      [Cell(0, 0), Cell(1, 0), Cell(0, 1), Cell(1, 1)],
      [Cell(0, 0), Cell(1, 0), Cell(0, 1), Cell(1, 1)],
    ],
    TetrominoType.I: [
      [Cell(-2, 0), Cell(-1, 0), Cell(0, 0), Cell(1, 0)],
      [Cell(0, -1), Cell(0, 0), Cell(0, 1), Cell(0, 2)],
      [Cell(-2, 0), Cell(-1, 0), Cell(0, 0), Cell(1, 0)],
      [Cell(0, -1), Cell(0, 0), Cell(0, 1), Cell(0, 2)],
    ],
    TetrominoType.T: [
      [Cell(-1, 0), Cell(0, 0), Cell(1, 0), Cell(0, 1)],
      [Cell(0, -1), Cell(0, 0), Cell(0, 1), Cell(1, 0)],
      [Cell(-1, 0), Cell(0, 0), Cell(1, 0), Cell(0, -1)],
      [Cell(0, -1), Cell(0, 0), Cell(0, 1), Cell(-1, 0)],
    ],
    TetrominoType.J: [
      [Cell(-1, 0), Cell(0, 0), Cell(1, 0), Cell(-1, 1)],
      [Cell(0, -1), Cell(0, 0), Cell(0, 1), Cell(1, 1)],
      [Cell(-1, 0), Cell(0, 0), Cell(1, 0), Cell(1, -1)],
      [Cell(0, -1), Cell(0, 0), Cell(0, 1), Cell(-1, -1)],
    ],
    TetrominoType.L: [
      [Cell(-1, 0), Cell(0, 0), Cell(1, 0), Cell(1, 1)],
      [Cell(0, -1), Cell(0, 0), Cell(0, 1), Cell(1, -1)],
      [Cell(-1, 0), Cell(0, 0), Cell(1, 0), Cell(-1, -1)],
      [Cell(0, -1), Cell(0, 0), Cell(0, 1), Cell(-1, 1)],
    ],
    TetrominoType.S: [
      [Cell(0, 0), Cell(1, 0), Cell(-1, 1), Cell(0, 1)],
      [Cell(0, -1), Cell(0, 0), Cell(1, 0), Cell(1, 1)],
      [Cell(0, 0), Cell(1, 0), Cell(-1, 1), Cell(0, 1)],
      [Cell(0, -1), Cell(0, 0), Cell(1, 0), Cell(1, 1)],
    ],
    TetrominoType.Z: [
      [Cell(-1, 0), Cell(0, 0), Cell(0, 1), Cell(1, 1)],
      [Cell(1, -1), Cell(1, 0), Cell(0, 0), Cell(0, 1)],
      [Cell(-1, 0), Cell(0, 0), Cell(0, 1), Cell(1, 1)],
      [Cell(1, -1), Cell(1, 0), Cell(0, 0), Cell(0, 1)],
    ],
  };

  List<Cell> blocksRelative([int? rot]) {
    final r = (rot ?? rotationIndex) & 3;
    return _shapes[type]![r];
  }

  List<Cell> blocksAbsolute() {
    final rel = blocksRelative();
    return rel.map((c) => Cell(originX + c.x, originY + c.y)).toList();
  }

  Tetromino rotatedClockwise() => copyWith(rotationIndex: rotationIndex + 1);

  Tetromino rotatedCounterclockwise() =>
      copyWith(rotationIndex: rotationIndex + 3);

  Tetromino shift(int dx, int dy) =>
      copyWith(originX: originX + dx, originY: originY + dy);
}
