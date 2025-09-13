import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/components/board_component.dart';
import 'package:tetris/components/hud_component.dart';
import 'package:tetris/game/timing.dart';
import 'package:tetris/model/board_model.dart';
import 'package:tetris/utils/set_extension.dart';

class TetrisGame extends FlameGame with KeyboardEvents {
  static const String pauseOverlayId = 'PauseOverlay';
  static const String gameOverOverlayId = 'GameOverOverlay';

  late final HudComponent hud;
  late BoardModel model;
  late BoardComponent boardComponent;

  bool _gameOverShown = false;

  int horizontalDirection = 0;
  bool softDrop = false;

  final Timing timing = Timing.defaults;

  late final Timer fallTimer;
  late final Timer lockTimer;
  late final Timer delayedAutoShiftTimer;
  late final Timer autoRepeatTimer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    model = BoardModel(rows: 20, cols: 10);
    boardComponent = BoardComponent(model: model);
    await world.add(boardComponent);

    hud = HudComponent(
      onTopInsetChanged: (double topInset) {
        boardComponent.topInset = topInset;
        boardComponent.onGameResize(boardComponent.size);
      },
    );
    await camera.viewport.add(hud);

    fallTimer = Timer(secs(timing.baseFall), onTick: _handleFallTick, repeat: true)
      ..start();

    lockTimer = Timer(
      secs(timing.lockDelay),
      onTick: () {
        if (!model.canMoveDown() && !model.isGameOver) {
          model.hardDropAndLock();
        }
      },
    );

    delayedAutoShiftTimer = Timer(
      secs(timing.delayedAutoShift),
      onTick: () {
        if (horizontalDirection != 0) {
          autoRepeatTimer.start();
        }
      },
      repeat: false,
    );

    autoRepeatTimer = Timer(
      secs(timing.autoRepeatRate),
      onTick: () {
        if (horizontalDirection == 0) {
          autoRepeatTimer.stop();
          return;
        }
        final moved = model.moveActive(horizontalDirection, 0);
        if (moved && !model.isGrounded()) {
          lockTimer.stop();
        }
      },
      repeat: true,
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

    if (model.isGameOver && !_gameOverShown) {
      _showGameOver();
      return;
    }

    final levelPeriod = model.fallPeriodForLevel(timing.baseFall);
    final targetPeriod = softDrop
        ? div(levelPeriod, timing.softDropFactor)
        : levelPeriod;

    final targetSecs = secs(targetPeriod);
    if ((fallTimer.limit - targetSecs).abs() > 1e-6) {
      fallTimer
        ..limit = targetSecs
        ..reset();
    }

    fallTimer.update(dt);
    lockTimer.update(dt);
    delayedAutoShiftTimer.update(dt);
    autoRepeatTimer.update(dt);

    hud.setSoftDrop(softDrop);
    hud.setScoreLinesLevel(
      score: model.score,
      lines: model.lines,
      level: model.level,
    );
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.keyP)) {
      togglePause();
      return KeyEventResult.handled;
    }

    if (paused) return KeyEventResult.handled;

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

    if (event is KeyUpEvent) {
      final leftHeldNow =
          keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keysPressed.contains(LogicalKeyboardKey.keyA);
      final rightHeldNow =
          keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD);

      if (!leftHeldNow && !rightHeldNow) {
        _stopHorizontalRepeat();
        return KeyEventResult.handled;
      }

      if (leftHeldNow && !rightHeldNow) {
        _stepOnceHorizontally(-1);
        _beginHorizontalRepeat(-1);
        return KeyEventResult.handled;
      }
      if (rightHeldNow && !leftHeldNow) {
        _stepOnceHorizontally(1);
        _beginHorizontalRepeat(1);
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          hit(LogicalKeyboardKey.keyS, PhysicalKeyboardKey.keyS)) {
        return KeyEventResult.handled;
      }

      if (hit(LogicalKeyboardKey.keyA, PhysicalKeyboardKey.keyA) ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _stepOnceHorizontally(-1);
        _beginHorizontalRepeat(-1);
        return KeyEventResult.handled;
      }

      if (hit(LogicalKeyboardKey.keyD, PhysicalKeyboardKey.keyD) ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _stepOnceHorizontally(1);
        _beginHorizontalRepeat(1);
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

      if (event.logicalKey == LogicalKeyboardKey.space) {
        model.hardDropAndLock();
        lockTimer.stop();
        return KeyEventResult.handled;
      }
    }

    if (softDrop) {
      return KeyEventResult.handled;
    }

    if (keysPressed.containsAny([
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyD,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
    ])) {
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void pauseGame() {
    if (_gameOverShown) return;
    if (paused) return;
    pauseEngine();
    overlays.add(pauseOverlayId);
  }

  void resumeGame() {
    if (_gameOverShown) return;
    if (!paused) return;
    overlays.remove(pauseOverlayId);
    resumeEngine();
  }

  void togglePause() => paused ? resumeGame() : pauseGame();

  Future<void> restartGame() async {
    final currentTopInset = boardComponent.topInset;
    final currentSideInset = boardComponent.sideInset;
    final currentBottomInset = boardComponent.bottomInset;

    boardComponent.removeFromParent();

    model = BoardModel(rows: 20, cols: 10);

    final newBoard = BoardComponent(
      model: model,
      topInset: currentTopInset,
      sideInset: currentSideInset,
      bottomInset: currentBottomInset,
    );
    boardComponent = newBoard;
    await world.add(newBoard);

    softDrop = false;
    final period = model.fallPeriodForLevel(timing.baseFall);
    fallTimer
      ..limit = secs(period)
      ..reset()
      ..start();

    lockTimer.stop();

    hud.setSoftDrop(false);
    hud.setScoreLinesLevel(score: 0, lines: 0, level: 1);
    hud.requestRelayout();

    overlays.remove(gameOverOverlayId);
    _gameOverShown = false;

    if (paused) resumeGame();
    if (!paused) resumeEngine();
  }

  void _setSoftDrop(bool enabled) {
    if (softDrop == enabled) return;
    softDrop = enabled;
    fallTimer.reset();
  }

  void _showGameOver() {
    if (_gameOverShown) return;

    fallTimer.stop();
    lockTimer.stop();

    pauseEngine();

    overlays.add(gameOverOverlayId);
    _gameOverShown = true;
  }

  void _beginHorizontalRepeat(int dir) {
    horizontalDirection = dir;
    autoRepeatTimer.stop();
    delayedAutoShiftTimer.stop();
    delayedAutoShiftTimer.start();
  }

  void _stopHorizontalRepeat() {
    horizontalDirection = 0;
    delayedAutoShiftTimer.stop();
    autoRepeatTimer.stop();
  }

  void _stepOnceHorizontally(int dir) {
    final moved = model.moveActive(dir, 0);
    if (moved && !model.isGrounded()) {
      lockTimer.stop();
    }
  }

  double secs(Duration d) => d.inMicroseconds / 1e6;
  Duration div(Duration d, double k) =>
      Duration(microseconds: (d.inMicroseconds / k).round());

  @override
  Color backgroundColor() => Colors.white;
}
