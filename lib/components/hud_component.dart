import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:tetris/game/tetris_game.dart';

class HudComponent extends PositionComponent with HasGameReference<TetrisGame> {
  final void Function(double topInset)? onTopInsetChanged;

  final double leftPadding;
  final double topPadding;
  final double gap;
  final double blockGap;
  final double bottomPadding;

  late final TextComponent hudTitle;
  late final TextComponent hudHint;
  late final TextComponent hudSoft;
  late final TextComponent hudScore;
  late final TextComponent hudLines;
  late final TextComponent hudLevel;

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
    this.onTopInsetChanged,
    this.leftPadding = 12,
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

    hudHint = TextComponent(
      text: '←/→/A/D move   Q/E/↑ rotate   [Space] drop',
      textRenderer: hintPaint,
    )..anchor = Anchor.topLeft;

    hudSoft = TextComponent(text: 'Soft: off', textRenderer: hintPaint)
      ..anchor = Anchor.topLeft;

    hudScore = TextComponent(text: 'Score: 0', textRenderer: valuePaint)
      ..anchor = Anchor.topLeft;
    hudLines = TextComponent(text: 'Lines: 0', textRenderer: valuePaint)
      ..anchor = Anchor.topLeft;
    hudLevel = TextComponent(text: 'Level: 1', textRenderer: valuePaint)
      ..anchor = Anchor.topLeft;

    await addAll([hudTitle, hudHint, hudSoft, hudScore, hudLines, hudLevel]);

    _relayout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _relayout();
  }

  void _relayout() {
    hudTitle.position = Vector2(leftPadding, topPadding);
    hudHint.position = Vector2(
      leftPadding,
      hudTitle.position.y + hudTitle.size.y + gap,
    );
    hudSoft.position = Vector2(
      leftPadding,
      hudHint.position.y + hudHint.size.y + gap,
    );

    final double blockGap = 8;
    hudScore.position = Vector2(
      leftPadding,
      hudSoft.position.y + hudSoft.size.y + blockGap,
    );
    hudLines.position = Vector2(
      leftPadding,
      hudScore.position.y + hudScore.size.y + gap,
    );
    hudLevel.position = Vector2(
      leftPadding,
      hudLines.position.y + hudLines.size.y + gap,
    );

    final double hudBottom = [
      hudTitle.position.y + hudTitle.size.y,
      hudHint.position.y + hudHint.size.y,
      hudSoft.position.y + hudSoft.size.y,
      hudScore.position.y + hudScore.size.y,
      hudLines.position.y + hudLines.size.y,
      hudLevel.position.y + hudLevel.size.y,
    ].reduce(math.max);

    onTopInsetChanged?.call(hudBottom + bottomPadding);
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
