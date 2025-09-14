import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/game/tetris_game.dart';

const double _dialogMaxWidth = 360;
const double _dialogCornerRadius = 12;
const double _dialogPadding = 20;
const double _backdropOpacity = 0.6;

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.score,
    required this.lines,
    required this.level,
    required this.onRestart,
  });

  factory GameOverOverlay.fromGame(TetrisGame game) => GameOverOverlay(
        score: game.model.score,
        lines: game.model.lines,
        level: game.model.level,
        onRestart: game.restartGame,
      );

  final int score;
  final int lines;
  final int level;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.enter): onRestart,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): onRestart,
        const SingleActivator(LogicalKeyboardKey.keyR): onRestart,
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: colorScheme.scrim.withValues(alpha: _backdropOpacity)),
          ),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
              child: Material(
                color: colorScheme.surface,
                elevation: 3,
                borderRadius: BorderRadius.circular(_dialogCornerRadius),
                child: Padding(
                  padding: const EdgeInsets.all(_dialogPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Game Over',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _StatRow(label: 'Score', value: '$score'),
                      const SizedBox(height: 6),
                      _StatRow(label: 'Lines', value: '$lines'),
                      const SizedBox(height: 6),
                      _StatRow(label: 'Level', value: '$level'),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onRestart,
                          child: const Text('Restart'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyLarge),
        Text(value, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}