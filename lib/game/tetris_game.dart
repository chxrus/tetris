import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/components/board_component.dart';
import 'package:tetris/model/board_model.dart';
import 'package:tetris/utils/set_extension.dart';

class TetrisGame extends FlameGame with KeyboardEvents {
  late final BoardModel model;
  late final BoardComponent boardComponent;

  TextComponent? hudTitle;
  TextComponent? hudHint;
  TextComponent? hudSoft;

  final double baseFall = 0.6;
  final double softDropFactor = 4.0;
  final double lockDelaySeconds = 0.5;

  bool softDrop = false;

  late final Timer fallTimer;
  late final Timer lockTimer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final text18 = TextPaint(
      style: const TextStyle(
        color: Color(0xFF111111),
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
    );
    final text12 = TextPaint(
      style: const TextStyle(
        color: Color(0xFF111111),
        fontSize: 20,
        fontWeight: FontWeight.w400,
      ),
    );

    hudTitle = TextComponent(text: 'TETRIS', textRenderer: text18)
      ..position = Vector2(12, 12)
      ..priority = 1000;

    hudHint =
        TextComponent(
            text: '←/→/A/D move   Q/E/↑ rotate   [Space] drop',
            textRenderer: text12,
          )
          ..position = Vector2(12, 48)
          ..priority = 1000;

    hudSoft = TextComponent(text: 'Soft: off', textRenderer: text12)
      ..position = Vector2(12, 72)
      ..priority = 1000;

    await camera.viewport.addAll([hudTitle!, hudHint!, hudSoft!]);

      final hudBottom = [
        hudTitle!.position.y + hudTitle!.size.y,
        hudHint!.position.y + hudHint!.size.y,
        hudSoft!.position.y + hudSoft!.size.y,
      ].reduce(math.max);
    final topInset = hudBottom + 12;

    model = BoardModel(rows: 20, cols: 10);
    boardComponent = BoardComponent(model: model, topInset: topInset);
    await world.add(boardComponent);

    fallTimer = Timer(baseFall, onTick: () => _handleFallTick(), repeat: true)
      ..start();

    lockTimer = Timer(
      lockDelaySeconds,
      onTick: () {
        if (!model.canMoveDown() && !model.isGameOver) {
          model.hardDropAndLock();
        }
      },
    );
  }

  void _handleFallTick() {
    if (model.isGameOver) return;

    final moved = model.fallOneCell();
    if (!moved) {
      if (!lockTimer.isRunning()) {
        lockTimer.start();
      }
    } else {
      lockTimer.stop();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    fallTimer.limit = softDrop ? (baseFall / softDropFactor) : baseFall;
    fallTimer.update(dt);
    lockTimer.update(dt);
    hudSoft!.text = 'Soft: ${softDrop ? 'on' : 'off'}';
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (model.isGameOver) {
      return KeyEventResult.ignored;
    }

    bool hit(LogicalKeyboardKey l, PhysicalKeyboardKey p) =>
        event.logicalKey == l || event.physicalKey == p;

    final softNow = keysPressed.containsAny([
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.arrowDown,
    ]);
    if (softNow != softDrop) _setSoftDrop(softNow);

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          hit(LogicalKeyboardKey.keyS, PhysicalKeyboardKey.keyS)) {
        return KeyEventResult.handled;
      }

      if (hit(LogicalKeyboardKey.keyA, PhysicalKeyboardKey.keyA) ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (model.moveActive(-1, 0) && !model.isGrounded()) {
          lockTimer.stop();
        }
        return KeyEventResult.handled;
      }

      if (hit(LogicalKeyboardKey.keyD, PhysicalKeyboardKey.keyD) ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (model.moveActive(1, 0) && !model.isGrounded()) {
          lockTimer.stop();
        }
        return KeyEventResult.handled;
      }

      if (hit(LogicalKeyboardKey.keyQ, PhysicalKeyboardKey.keyQ)) {
        if (model.rotateActiveCounterclockwise() && !model.isGrounded()) {
          lockTimer.stop();
        }
        return KeyEventResult.handled;
      }

      if (hit(LogicalKeyboardKey.keyE, PhysicalKeyboardKey.keyE) ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (model.rotateActiveClockwise() && !model.isGrounded()) {
          lockTimer.stop();
        }
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.space) {
      model.hardDropAndLock();
      lockTimer.stop();
      return KeyEventResult.handled;
    }

    if (softDrop) {
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _setSoftDrop(bool enabled) {
    if (softDrop == enabled) return;
    softDrop = enabled;
    fallTimer.reset();
  }

  @override
  Color backgroundColor() => Colors.white;
}
