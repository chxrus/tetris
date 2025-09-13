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

  final double baseFall = 0.6;
  final double softDropFactor = 4.0;
  final double lockDelaySeconds = 0.5;

  bool softDrop = false;

  late final Timer fallTimer;
  late final Timer lockTimer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    model = BoardModel(rows: 20, cols: 10);
    boardComponent = BoardComponent(model: model);
    await add(boardComponent);

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
