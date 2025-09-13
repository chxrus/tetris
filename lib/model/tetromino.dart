class Cell {
  final int x, y;
  const Cell(this.x, this.y);
}

enum TetrominoType { I, O, T, J, L, S, Z }

class Tetromino {
  TetrominoType type;
  int rotationIndex; // 0..3
  int originX;
  int originY;

  Tetromino({
    required this.type,
    required this.originX,
    required this.originY,
    this.rotationIndex = 0,
  });

  static const Map<TetrominoType, List<List<Cell>>> _shapes = {
    TetrominoType.O: [
      [Cell(0,0), Cell(1,0), Cell(0,1), Cell(1,1)],
      [Cell(0,0), Cell(1,0), Cell(0,1), Cell(1,1)],
      [Cell(0,0), Cell(1,0), Cell(0,1), Cell(1,1)],
      [Cell(0,0), Cell(1,0), Cell(0,1), Cell(1,1)],
    ],
    TetrominoType.I: [
      [Cell(-2,0), Cell(-1,0), Cell(0,0), Cell(1,0)],
      [Cell(0,-1), Cell(0,0), Cell(0,1), Cell(0,2)],
      [Cell(-2,0), Cell(-1,0), Cell(0,0), Cell(1,0)],
      [Cell(0,-1), Cell(0,0), Cell(0,1), Cell(0,2)],
    ],
    TetrominoType.T: [
      [Cell(-1,0), Cell(0,0), Cell(1,0), Cell(0,1)],
      [Cell(0,-1), Cell(0,0), Cell(0,1), Cell(1,0)],
      [Cell(-1,0), Cell(0,0), Cell(1,0), Cell(0,-1)],
      [Cell(0,-1), Cell(0,0), Cell(0,1), Cell(-1,0)],
    ],
    TetrominoType.J: [
      [Cell(-1,0), Cell(0,0), Cell(1,0), Cell(-1,1)],
      [Cell(0,-1), Cell(0,0), Cell(0,1), Cell(1,1)],
      [Cell(-1,0), Cell(0,0), Cell(1,0), Cell(1,-1)],
      [Cell(0,-1), Cell(0,0), Cell(0,1), Cell(-1,-1)],
    ],
    TetrominoType.L: [
      [Cell(-1,0), Cell(0,0), Cell(1,0), Cell(1,1)],
      [Cell(0,-1), Cell(0,0), Cell(0,1), Cell(1,-1)],
      [Cell(-1,0), Cell(0,0), Cell(1,0), Cell(-1,-1)],
      [Cell(0,-1), Cell(0,0), Cell(0,1), Cell(-1,1)],
    ],
    TetrominoType.S: [
      [Cell(0,0), Cell(1,0), Cell(-1,1), Cell(0,1)],
      [Cell(0,-1), Cell(0,0), Cell(1,0), Cell(1,1)],
      [Cell(0,0), Cell(1,0), Cell(-1,1), Cell(0,1)],
      [Cell(0,-1), Cell(0,0), Cell(1,0), Cell(1,1)],
    ],
    TetrominoType.Z: [
      [Cell(-1,0), Cell(0,0), Cell(0,1), Cell(1,1)],
      [Cell(1,-1), Cell(1,0), Cell(0,0), Cell(0,1)],
      [Cell(-1,0), Cell(0,0), Cell(0,1), Cell(1,1)],
      [Cell(1,-1), Cell(1,0), Cell(0,0), Cell(0,1)],
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

  void rotateClockwise()        => rotationIndex = (rotationIndex + 1) & 3;
  void rotateCounterclockwise() => rotationIndex = (rotationIndex + 3) & 3;
  void shift(int dx, int dy) { originX += dx; originY += dy; }
}
