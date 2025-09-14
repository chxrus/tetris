import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:tetris/config/metrics.dart';
import 'package:tetris/model/models.dart';
import 'package:tetris/utils/function_aliases.dart';

class NextTetrominoPreview extends PositionComponent {
  final TetrominoColorResolver colorOfTetromino;

  TetrominoType? _type;
  final double padding;
  final double cellGap;

  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = Metrics.gridBorder
    ..color = const Color(0xFF2A2A30);

  final Paint _cellPaint = Paint()..style = PaintingStyle.fill;

  NextTetrominoPreview({
    required this.colorOfTetromino,
    Vector2? boxSize,
    this.padding = 6,
    this.cellGap = 1,
  }) {
    size = boxSize ?? Vector2(96, 96);
    anchor = Anchor.topLeft;
  }

  void setType(TetrominoType? type) {
    if (_type == type) return;
    _type = type;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_type == null) return;

    canvas.drawRect(Offset.zero & Size(size.x, size.y), _borderPaint);

    final Tetromino tetromino = Tetromino.spawn(
      type: _type!,
      originX: 0,
      originY: 0,
    );
    final List<Cell> cells = tetromino.blocksRelative();

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

    _cellPaint.color = Color(colorOfTetromino(_type!));

    for (final c in cells) {
      final localX = (c.x - minX) * cellSize;
      final localY = (c.y - minY) * cellSize;

      final rect = Rect.fromLTWH(
        dx + localX + cellGap,
        dy + localY + cellGap,
        cellSize - cellGap * 2,
        cellSize - cellGap * 2,
      );
      canvas.drawRect(rect, _cellPaint);
    }
  }
}
