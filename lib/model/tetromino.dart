import 'package:flutter/foundation.dart';
import 'package:tetris/model/tetromino_type.dart';
import 'package:tetris/model/cell.dart';

@immutable
class Tetromino {
  static const Map<TetrominoType, int> palette = {
    TetrominoType.I: 0xFF00BCD4, // cyan
    TetrominoType.J: 0xFF1E88E5, // blue
    TetrominoType.L: 0xFFF57C00, // orange
    TetrominoType.O: 0xFFFBC02D, // yellow
    TetrominoType.S: 0xFF43A047, // green
    TetrominoType.T: 0xFF8E24AA, // purple
    TetrominoType.Z: 0xFFE53935, // red
  };

  static int colorOf(TetrominoType type) => palette[type]!;

  final TetrominoType type;
  final int originX;
  final int originY;
  final int rotationIndex;
  final int colorValue;

  const Tetromino({
    required this.type,
    required this.originX,
    required this.originY,
    required this.rotationIndex,
    required this.colorValue,
  });

  factory Tetromino.spawn({
    required TetrominoType type,
    required int originX,
    required int originY,
  }) {
    return Tetromino(
      type: type,
      originX: originX,
      originY: originY,
      rotationIndex: 0,
      colorValue: colorOf(type),
    );
  }

  Tetromino copyWith({
    TetrominoType? type,
    int? originX,
    int? originY,
    int? rotationIndex,
    int? colorValue,
  }) {
    return Tetromino(
      type: type ?? this.type,
      originX: originX ?? this.originX,
      originY: originY ?? this.originY,
      rotationIndex: (rotationIndex ?? this.rotationIndex) & 3,
      colorValue: colorValue ?? this.colorValue,
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

  List<Cell> blocksRelative([int? rotation]) {
    final int r = (rotation ?? rotationIndex) & 3;
    return _shapes[type]![r];
  }

  List<Cell> blocksAbsolute() {
    final rel = blocksRelative();
    return <Cell>[
      Cell(originX + rel[0].x, originY + rel[0].y),
      Cell(originX + rel[1].x, originY + rel[1].y),
      Cell(originX + rel[2].x, originY + rel[2].y),
      Cell(originX + rel[3].x, originY + rel[3].y),
    ];
  }

  Tetromino rotatedClockwise() => copyWith(rotationIndex: rotationIndex + 1);
  Tetromino rotatedCounterclockwise() => copyWith(rotationIndex: rotationIndex + 3);
  Tetromino shift(int dx, int dy) => copyWith(originX: originX + dx, originY: originY + dy);
}
