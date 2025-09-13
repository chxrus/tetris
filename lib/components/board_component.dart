import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:tetris/game/tetris_game.dart';
import 'package:tetris/model/board_model.dart';

class BoardComponent extends PositionComponent
    with HasGameReference<TetrisGame> {
  static const rows = 20;
  static const cols = 10;

  final BoardModel model;
  final Map<int, Paint> _paintCache = {};

  double topInset;
  double sideInset;
  double bottomInset;

  double cell = 24.0;

  BoardComponent({
    required this.model,
    this.topInset = 72,
    this.sideInset = 16,
    this.bottomInset = 16,
  }) {
    anchor = Anchor.topLeft;
    priority = 0;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _relayout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _relayout();
  }

  void _relayout() {
    final viewportSize = game.camera.viewport.size;

    final contentW = viewportSize.x - sideInset * 2;
    final contentH = viewportSize.y - topInset - bottomInset;

    cell = math
        .min(contentW / model.cols, contentH / model.rows)
        .floorToDouble()
        .clamp(1.0, double.infinity);

    size.setValues(model.cols * cell, model.rows * cell);

    final offsetX = (viewportSize.x - size.x) / 2;
    final offsetY = topInset + (contentH - size.y) / 2;

    position.setValues(offsetX, offsetY);
  }

  final gridPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final piecePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF42A5F5);

  Paint _paintFor(int colorValue) {
    return _paintCache.putIfAbsent(
      colorValue,
      () => Paint()
        ..style = PaintingStyle.fill
        ..color = Color(colorValue),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final halfBorder = borderPaint.strokeWidth / 2;
    final rect = Rect.fromLTWH(
      halfBorder,
      halfBorder,
      size.x - borderPaint.strokeWidth,
      size.y - borderPaint.strokeWidth,
    );
    canvas.drawRect(rect, borderPaint);

    final halfGrid = gridPaint.strokeWidth / 2;
    for (var c = 1; c < model.cols; c++) {
      final x = c * cell + halfGrid;
      canvas.drawLine(
        Offset(x, halfGrid),
        Offset(x, size.y - halfGrid),
        gridPaint,
      );
    }
    for (var r = 1; r < model.rows; r++) {
      final y = r * cell + halfGrid;
      canvas.drawLine(
        Offset(halfGrid, y),
        Offset(size.x - halfGrid, y),
        gridPaint,
      );
    }

    for (var y = 0; y < model.rows; y++) {
      for (var x = 0; x < model.cols; x++) {
        if (model.cells[y][x] != 0) {
          final colorValue = model.cells[y][x];
          final cellRect = Rect.fromLTWH(
            halfBorder + x * cell + 1,
            halfBorder + y * cell + 1,
            cell - 2,
            cell - 2,
          );
          canvas.drawRect(cellRect, _paintFor(colorValue));
        }
      }
    }

    if (model.active != null && !model.isGameOver) {
      for (final c in model.active!.blocksAbsolute()) {
        final rect = Rect.fromLTWH(
          halfBorder + c.x * cell + 2,
          halfBorder + c.y * cell + 2,
          cell - 4,
          cell - 4,
        );
        canvas.drawRect(rect, piecePaint);
      }
    }
  }
}
