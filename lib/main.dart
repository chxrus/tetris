import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tetris/game/tetris_game.dart';
import 'package:tetris/ui/overlays/overlays.dart';
import 'package:tetris/theme/app_theme.dart';
import 'package:tetris/theme/game_palette.dart';
import 'package:tetris/config/palettes.dart';
import 'package:tetris/ui/overlays/theme_overlay.dart';

void main() => runApp(const TetrisApp());

class TetrisApp extends StatefulWidget {
  const TetrisApp({super.key});

  @override
  State<TetrisApp> createState() => _TetrisAppState();
}

class _TetrisAppState extends State<TetrisApp> {
  final ValueNotifier<GamePalette> paletteNotifier = ValueNotifier(
    Palettes.dark(),
  );
  
  late TetrisGame tetrisGame = TetrisGame(palette: paletteNotifier.value);

  void _applyPalette(GamePalette newPalette) {
    setState(() {
      paletteNotifier.value = newPalette;
      tetrisGame = TetrisGame(palette: newPalette);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GamePalette>(
      valueListenable: paletteNotifier,
      builder: (context, currentPalette, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.fromPalette(currentPalette),
          home: GameWidget(
            key: ValueKey(currentPalette.gameBackground.toARGB32()),
            game: tetrisGame,
            overlayBuilderMap: {
              TetrisGame.pauseOverlayId: (context, _) =>
                  PauseOverlay.fromGame(tetrisGame),
              TetrisGame.gameOverOverlayId: (context, _) =>
                  GameOverOverlay.fromGame(tetrisGame),
              TetrisGame.themeOverlayId: (context, _) => ThemeOverlay(
                selected: currentPalette,
                onPick: (picked) {
                  _applyPalette(picked);
                  tetrisGame.overlays.remove(TetrisGame.themeOverlayId);
                },
                onClose: () =>
                    tetrisGame.overlays.remove(TetrisGame.themeOverlayId),
              ),
            },
          ),
        );
      },
    );
  }
}
