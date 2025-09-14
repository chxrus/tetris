import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/game/tetris_game.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    this.onOpenTheme,
  });

  factory PauseOverlay.fromGame(TetrisGame game) => PauseOverlay(
    onResume: game.resumeGame,
    onRestart: game.restartGame,
    onOpenTheme: () => game.overlays.add(TetrisGame.themeOverlayId),
  );

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback? onOpenTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): onResume,
        const SingleActivator(LogicalKeyboardKey.enter): onResume,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): onResume,
        const SingleActivator(LogicalKeyboardKey.keyR): onRestart,
        if (onOpenTheme != null)
          const SingleActivator(LogicalKeyboardKey.keyT): onOpenTheme!,
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onResume,
              behavior: HitTestBehavior.opaque,
              child: ColoredBox(
                color: colorScheme.scrim.withValues(alpha: 0.6),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Material(
                color: colorScheme.surface,
                elevation: 3,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FocusTraversalGroup(
                    policy: OrderedTraversalPolicy(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Paused',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: onResume,
                            child: const Text('Continue'),
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (onOpenTheme != null) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: onOpenTheme,
                              child: const Text('Theme…'),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
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
          ),
        ],
      ),
    );
  }
}
