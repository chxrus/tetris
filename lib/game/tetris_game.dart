import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/components/board_component.dart';
import 'package:tetris/model/board_model.dart';

class TetrisGame extends FlameGame with KeyboardEvents {
  late final BoardModel model;
  late final BoardComponent boardComponent;
  
  final double baseFall = 0.6;
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

    fallTimer = Timer(
      baseFall,
      onTick: () => _handleFallTick(),
      repeat: true,
    )..start();

    lockTimer = Timer(
      lockDelaySeconds, 
      onTick: () {
      if (!model.canMoveDown() && !model.isGameOver) {
        model.hardDropAndLock();
      }
    });
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
    fallTimer.limit = softDrop ? baseFall / 10 : baseFall;
    fallTimer.update(dt);
    lockTimer.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    softDrop = keysPressed.contains(LogicalKeyboardKey.arrowDown);

    final isDown = event is KeyDownEvent;
    if (!isDown || model.isGameOver) return KeyEventResult.ignored;

    bool isKey(LogicalKeyboardKey l, PhysicalKeyboardKey p) =>
        event.logicalKey == l || event.physicalKey == p;

    if (isKey(LogicalKeyboardKey.keyA, PhysicalKeyboardKey.keyA) ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      model.tryShiftHorizontal(-1);
      return KeyEventResult.handled;
    }
    if (isKey(LogicalKeyboardKey.keyD, PhysicalKeyboardKey.keyD) ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      model.tryShiftHorizontal(1);
      return KeyEventResult.handled;
    }
    if (isKey(LogicalKeyboardKey.keyQ, PhysicalKeyboardKey.keyQ)) {
      model.rotateCounterclockwise();
      return KeyEventResult.handled;
    }
    if (isKey(LogicalKeyboardKey.keyE, PhysicalKeyboardKey.keyE) ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      model.rotateClockwise();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.space) {
      model.hardDropAndLock();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Color backgroundColor() => Colors.white;
}
