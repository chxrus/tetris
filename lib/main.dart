import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'package:tetris/game/tetris_game.dart';
import 'package:tetris/theme/app_theme.dart';
import 'package:tetris/theme/game_palette.dart';
import 'package:tetris/ui/overlays/overlays.dart';

void main() {
  final GamePalette palette = GamePalette.lightWarm();
  final TetrisGame game = TetrisGame(palette: palette);

  runApp(
    MaterialApp(
      theme: AppTheme.fromPalette(palette),
      home: GameWidget<TetrisGame>(
        game: game,
        overlayBuilderMap: {
          TetrisGame.pauseOverlayId: (context, gameRef) => PauseOverlay.fromGame(gameRef),
          TetrisGame.gameOverOverlayId: (context, gameRef) => GameOverOverlay.fromGame(gameRef),
        },
      ),
    ),
  );
}
