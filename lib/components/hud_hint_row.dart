import 'dart:math' as math;
import 'package:flame/components.dart';

class HudHintRow extends PositionComponent {
  final TextComponent keys;
  final TextComponent label;
  final double gap;

  HudHintRow({
    required String keysText,
    required String labelText,
    required TextPaint keysPaint,
    required TextPaint labelPaint,
    this.gap = 8,
  }) : keys = TextComponent(text: keysText, textRenderer: keysPaint),
       label = TextComponent(text: labelText, textRenderer: labelPaint);

  @override
  Future<void> onLoad() async {
    await addAll([keys, label]);
    _layout();
  }

  void _layout() {
    keys.anchor = Anchor.topLeft;
    label.anchor = Anchor.topLeft;

    keys.position = Vector2.zero();
    label.position = Vector2(
      keys.size.x + gap,
      (keys.size.y - label.size.y) / 2,
    );

    size = Vector2(
      keys.size.x + gap + label.size.x,
      math.max(keys.size.y, label.size.y),
    );
  }
}
