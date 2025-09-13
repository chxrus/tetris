import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:tetris/model/board_model.dart';

class BoardComponent extends PositionComponent {
  static const double padding = 32;

  final BoardModel model;

  BoardComponent({required this.model}) {
    anchor = Anchor.center;
  }

  double cell = 24.0;

  final gridPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  final piecePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF42A5F5);

  final stackPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF212121);

  @override
  Future<void> onLoad() async {
    size = Vector2(model.cols * cell, model.rows * cell);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    final maxCellWidth  = (gameSize.x - padding * 2) / model.cols;
    final maxCellHeight = (gameSize.y - padding * 2) / model.rows;
    cell = math.min(maxCellWidth, maxCellHeight).floorToDouble().clamp(1.0, double.infinity);
    size.setValues(model.cols * cell, model.rows * cell);
    position = gameSize / 2;
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
      canvas.drawLine(Offset(x, halfGrid), Offset(x, size.y - halfGrid), gridPaint);
    }
    for (var r = 1; r < model.rows; r++) {
      final y = r * cell + halfGrid;
      canvas.drawLine(Offset(halfGrid, y), Offset(size.x - halfGrid, y), gridPaint);
    }

    for (var y = 0; y < model.rows; y++) {
      for (var x = 0; x < model.cols; x++) {
        if (model.cells[y][x] != 0) {
          final cellRect = Rect.fromLTWH(
            halfBorder + x * cell + 1,
            halfBorder + y * cell + 1,
            cell - 2,
            cell - 2,
          );
          canvas.drawRect(cellRect, stackPaint);
        }
      }
    }

    final activeRect = Rect.fromLTWH(
      halfBorder + model.activeX * cell + 2,
      halfBorder + model.activeY * cell + 2,
      cell - 4,
      cell - 4,
    );
    canvas.drawRect(activeRect, piecePaint);
  }
}
