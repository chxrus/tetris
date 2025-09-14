import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:tetris/components/hud_hint_row.dart';
import 'package:tetris/game/tetris_game.dart';

class HudComponent extends PositionComponent with HasGameReference<TetrisGame> {
  final void Function(double topInset, double leftInset, double rightInset)?
  onInsetsChanged;

  final double leftPadding;
  final double rightPadding;
  final double topPadding;
  final double gap;
  final double blockGap;
  final double bottomPadding;

  late final TextComponent hudTitle;
  late final TextComponent hudSoft;
  late final TextComponent hudScore;
  late final TextComponent hudLines;
  late final TextComponent hudLevel;
  late final List<HudHintRow> hintRows;

  final TextPaint hintKeysPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFF111111),
      fontSize: 18,
      fontWeight: FontWeight.w700, // жирные клавиши
    ),
  );
  final TextPaint hintTextPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFF111111),
      fontSize: 18,
      fontWeight: FontWeight.w400, // обычный текст
    ),
  );
  final TextPaint titlePaint = TextPaint(
    style: TextStyle(
      color: Color(0xFF111111),
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
  );
  final TextPaint hintPaint = TextPaint(
    style: TextStyle(
      color: Color(0xFF111111),
      fontSize: 18,
      fontWeight: FontWeight.w400,
    ),
  );
  final TextPaint valuePaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFF111111),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  HudComponent({
    this.onInsetsChanged,
    this.leftPadding = 12,
    this.rightPadding = 12,
    this.topPadding = 12,
    this.gap = 4,
    this.blockGap = 12,
    this.bottomPadding = 12,
  }) {
    anchor = Anchor.topLeft;
    priority = 1000;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    hudTitle = TextComponent(text: 'TETRIS', textRenderer: titlePaint)
      ..anchor = Anchor.topLeft;

    hintRows = [
      HudHintRow(
        keysText: '← / → / A / D',
        labelText: 'move',
        keysPaint: hintKeysPaint,
        labelPaint: hintTextPaint,
      ),
      HudHintRow(
        keysText: 'Q / E / ↑',
        labelText: 'rotate',
        keysPaint: hintKeysPaint,
        labelPaint: hintTextPaint,
      ),
      HudHintRow(
        keysText: '[Space]',
        labelText: 'drop',
        keysPaint: hintKeysPaint,
        labelPaint: hintTextPaint,
      ),
      HudHintRow(
        keysText: 'S / ↓',
        labelText: 'soft',
        keysPaint: hintKeysPaint,
        labelPaint: hintTextPaint,
      ),
    ];

    hudSoft = TextComponent(text: 'Soft: off', textRenderer: hintPaint)
      ..anchor = Anchor.topLeft;

    hudScore = TextComponent(text: 'Score: 0', textRenderer: valuePaint)
      ..anchor = Anchor.topLeft;
    hudLines = TextComponent(text: 'Lines: 0', textRenderer: valuePaint)
      ..anchor = Anchor.topLeft;
    hudLevel = TextComponent(text: 'Level: 1', textRenderer: valuePaint)
      ..anchor = Anchor.topLeft;

    await addAll([
      hudTitle,
      ...hintRows,
      hudSoft,
      hudScore,
      hudLines,
      hudLevel,
    ]);

    _relayout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _relayout();
  }

  void _relayout() {
    final viewportSize = game.camera.viewport.size;

    hudTitle.position = Vector2(
      (viewportSize.x - hudTitle.size.x) / 2,
      topPadding,
    );
    final topInset = hudTitle.position.y + hudTitle.size.y + bottomPadding;

    final double hintsTotalHeight = hintRows.isEmpty
        ? 0
        : hintRows.map((r) => r.size.y).reduce((a, b) => a + b) +
              (hintRows.length - 1) * gap;

    double y = (viewportSize.y - (hintsTotalHeight + gap + hudSoft.size.y)) / 2;
    double leftPanelMaxWidth = 0;

    for (final row in hintRows) {
      row.position = Vector2(leftPadding, y);
      y += row.size.y + gap;
      leftPanelMaxWidth = math.max(leftPanelMaxWidth, row.size.x);
    }

    hudSoft.position = Vector2(leftPadding, y);
    leftPanelMaxWidth = math.max(leftPanelMaxWidth, hudSoft.size.x);
    final leftPanelWidth = leftPanelMaxWidth;
    final leftInset = leftPadding + leftPanelWidth + blockGap;

    final rightPanelWidth = [
      hudScore.size.x,
      hudLines.size.x,
      hudLevel.size.x,
    ].reduce(math.max);
    final rightPanelHeight =
        hudScore.size.y + gap + hudLines.size.y + gap + hudLevel.size.y;

    final rightX = viewportSize.x - rightPadding - rightPanelWidth;
    final rightY = (viewportSize.y - rightPanelHeight) / 2;

    hudScore.position = Vector2(rightX, rightY);
    hudLines.position = Vector2(
      rightX,
      hudScore.position.y + hudScore.size.y + gap,
    );
    hudLevel.position = Vector2(
      rightX,
      hudLines.position.y + hudLines.size.y + gap,
    );

    final rightInset = rightPadding + rightPanelWidth + blockGap;

    onInsetsChanged?.call(topInset, leftInset, rightInset);
  }

  void setSoftDrop(bool enabled) {
    final next = 'Soft: ${enabled ? 'on' : 'off'}';
    if (hudSoft.text != next) {
      hudSoft.text = next;
    }
  }

  void setScoreLinesLevel({
    required int score,
    required int lines,
    required int level,
  }) {
    final nextScore = 'Score: $score';
    final nextLines = 'Lines: $lines';
    final nextLevel = 'Level: $level';
    if (hudScore.text != nextScore) hudScore.text = nextScore;
    if (hudLines.text != nextLines) hudLines.text = nextLines;
    if (hudLevel.text != nextLevel) hudLevel.text = nextLevel;
  }

  void requestRelayout() => _relayout();
}
