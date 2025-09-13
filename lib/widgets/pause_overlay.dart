import 'package:flutter/material.dart';
import 'package:tetris/game/tetris_game.dart';

class PauseOverlay extends StatelessWidget {
  final TetrisGame game;

  final Color buttonColor;
  final Color buttonTextColor;

  const PauseOverlay({
    super.key,
    required this.game,
    this.buttonColor = Colors.black, 
    this.buttonTextColor = Colors.white,
  });

  factory PauseOverlay.black({required TetrisGame game}) =>
      PauseOverlay(game: game);
      
  factory PauseOverlay.blue({required TetrisGame game}) =>
      PauseOverlay(
        game: game,
        buttonColor: Colors.blue, 
        buttonTextColor: Colors.white,
      );

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: buttonTextColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0, // современно плоско
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ).copyWith(
      overlayColor: WidgetStatePropertyAll(
        buttonTextColor.withValues(alpha: 0.10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _buttonStyle();

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: Colors.black54)),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Paused',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: game.resumeGame,
                      style: style,
                      child: const Text('Continue'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: game.restartGame,
                      style: style,
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
