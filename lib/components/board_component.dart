import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tetris/components/board_effects.dart';
import 'package:tetris/game/tetris_game.dart';
import 'package:tetris/model/models.dart';
import 'package:tetris/utils/function_aliases.dart';

class BoardComponent extends PositionComponent
    with HasGameReference<TetrisGame> {
  static const rows = 20;
  static const cols = 10;

  late final BoardEffects fx;

  final TetrominoColorResolver colorOfTetromino;

  final BoardModel model;
  final Map<int, Paint> _paintCache = {};

  double topInset;
  double leftInset;
  double rightInset;
  double bottomInset;

  double cell = 24.0;

  final Paint gridPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  final Paint borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  late Paint _boardFillPaint;

  BoardComponent({
    required this.model,
    required this.colorOfTetromino,
    this.topInset = 72,
    this.leftInset = 16,
    this.rightInset = 16,
    this.bottomInset = 16,
  }) {
    anchor = Anchor.topLeft;
    priority = 0;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    fx = BoardEffects();
    await add(fx);

    final gamePalette = game.palette;

    _boardFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = gamePalette.boardBackground;

    gridPaint.color = gamePalette.boardGrid;
    borderPaint.color = gamePalette.boardBorder;

    _relayout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _relayout();
  }

  void _relayout() {
    final viewportSize = game.camera.viewport.size;

    final contentW = (viewportSize.x - leftInset - rightInset).clamp(
      1,
      double.infinity,
    );
    final contentH = (viewportSize.y - topInset - bottomInset).clamp(
      1,
      double.infinity,
    );

    cell = math
        .min(contentW / model.cols, contentH / model.rows)
        .floorToDouble()
        .clamp(1.0, double.infinity);

    size.setValues(model.cols * cell, model.rows * cell);

    final offsetX = (viewportSize.x - size.x) / 2;
    final offsetY = topInset + (contentH - size.y) / 2;

    position.setValues(offsetX, offsetY);
  }

  Paint _paintForColorValue(int argb) {
    return _paintCache.putIfAbsent(
      argb,
      () => Paint()
        ..style = PaintingStyle.fill
        ..color = Color(argb),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final halfBorder = borderPaint.strokeWidth / 2;
    canvas.drawRect(Offset.zero & Size(size.x, size.y), _boardFillPaint);

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
          final int code = model.cells[y][x];
          final cellRect = Rect.fromLTWH(
            halfBorder + x * cell + 1,
            halfBorder + y * cell + 1,
            cell - 2,
            cell - 2,
          );
          if (code != 0) {
            final int code = model.cells[y][x];
            final type = TetrominoType.values[code - 1];
            final colorValue = colorOfTetromino(type);
            canvas.drawRect(cellRect, _paintForColorValue(colorValue));
          }
        }
      }
    }

    if (model.active != null && !model.isGameOver) {
      final TetrominoType activeType = model.active!.type;
      final int activeColorValue = colorOfTetromino(activeType);
      final Paint activePaint = _paintForColorValue(activeColorValue);

      for (final c in model.active!.blocksAbsolute()) {
        final rect = Rect.fromLTWH(
          halfBorder + c.x * cell + 2,
          halfBorder + c.y * cell + 2,
          cell - 4,
          cell - 4,
        );
        canvas.drawRect(rect, activePaint);
      }
    }

    final frameRect = Rect.fromLTWH(
      halfBorder,
      halfBorder,
      size.x - borderPaint.strokeWidth,
      size.y - borderPaint.strokeWidth,
    );
    canvas.drawRect(frameRect, borderPaint);
  }

  void flashRows(List<int> rows) {
    fx.flashRows(rows: rows, cell: cell, width: size.x);
  }

  void landingBurst(Iterable<Cell> cells, TetrominoType type) {
    final centers = cells.map(
      (c) => Vector2((c.x + 0.5) * cell, (c.y + 0.5) * cell),
    );
    final colorValue = colorOfTetromino(type);
    fx.spawnLandingParticles(worldCenters: centers, colorValue: colorValue);
  }
}
