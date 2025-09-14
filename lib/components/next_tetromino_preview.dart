import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:tetris/model/tetromino.dart';

class NextTetrominoPreview extends PositionComponent {
  TetrominoType? _type;
  double padding;
  double cellGap;

  final Paint _fill = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Colors.black;

  NextTetrominoPreview({Vector2? boxSize, this.padding = 6, this.cellGap = 1}) {
    size = boxSize ?? Vector2(96, 96);
    anchor = Anchor.topLeft;
  }

  void setType(TetrominoType? t) {
    if (_type == t) return;
    _type = t;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_type == null) return;

    canvas.drawRect(Offset.zero & Size(size.x, size.y), _fill);

    final t = Tetromino(
      type: _type!,
      originX: 0,
      originY: 0,
      rotationIndex: 0,
      colorValue: Tetromino.colorOf(_type!),
    );
    final cells = t.blocksRelative();

    int minX = 1 << 30, maxX = -1 << 30, minY = 1 << 30, maxY = -1 << 30;
    for (final c in cells) {
      if (c.x < minX) minX = c.x;
      if (c.x > maxX) maxX = c.x;
      if (c.y < minY) minY = c.y;
      if (c.y > maxY) maxY = c.y;
    }
    final wCells = (maxX - minX + 1);
    final hCells = (maxY - minY + 1);

    final availW = size.x - padding * 2;
    final availH = size.y - padding * 2;

    final cellSize = math.min(availW / wCells, availH / hCells);

    final contentW = wCells * cellSize;
    final contentH = hCells * cellSize;
    final dx = (size.x - contentW) / 2;
    final dy = (size.y - contentH) / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(Tetromino.colorOf(_type!));

    for (final c in cells) {
      final localX = (c.x - minX) * cellSize;
      final localY = (c.y - minY) * cellSize;

      final rect = Rect.fromLTWH(
        dx + localX + cellGap,
        dy + localY + cellGap,
        cellSize - cellGap * 2,
        cellSize - cellGap * 2,
      );
      canvas.drawRect(rect, paint);
    }
  }
}
