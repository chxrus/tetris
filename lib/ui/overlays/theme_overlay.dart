import 'package:flutter/material.dart';
import 'package:tetris/theme/game_palette.dart';
import 'package:tetris/config/palettes.dart';

class ThemeOverlay extends StatelessWidget {
  final GamePalette selected;
  final void Function(GamePalette palette) onPick;
  final VoidCallback onClose;

  const ThemeOverlay({
    super.key,
    required this.selected,
    required this.onPick,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final presets = Palettes.all();
    final currentName = Palettes.nameOf(selected);
    final cs = Theme.of(context).colorScheme;

    return Stack(children: [
      Positioned.fill(
        child: GestureDetector(
          onTap: onClose,
          child: ColoredBox(color: cs.scrim.withValues(alpha: 0.4)),
        ),
      ),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Material(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Choose Theme', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),

                // Прокручиваемый список с ограничением по высоте
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: presets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, i) {
                      final preset = presets[i];
                      final name = preset.name;
                      final palette = preset.palette;
                      final selectedNow = name == currentName;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        minLeadingWidth: 0,
                        horizontalTitleGap: 8,
                        dense: true,
                        leading: _Swatch(palette: palette),
                        title: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: selectedNow ? const Icon(Icons.check_rounded) : null,
                        onTap: () => onPick(palette),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: onClose, child: const Text('Close')),
                ),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _Swatch extends StatelessWidget {
  final GamePalette palette;
  const _Swatch({required this.palette});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64, 
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _DotGetter((p) => p.gameBackground),
        SizedBox(width: 4),
        _DotGetter((p) => p.boardBackground),
        SizedBox(width: 4),
        _DotGetter((p) => p.boardBorder),
        SizedBox(width: 4),
        _DotGetter((p) => p.boardGrid),
      ].map((w) => w is _DotGetter ? w.withPalette(palette) : w).toList()),
    );
  }
}

// маленький хелпер, чтобы не повторять код
class _DotGetter extends StatelessWidget {
  final Color Function(GamePalette) pick;
  final GamePalette? _palette;
  const _DotGetter(this.pick) : _palette = null;
  const _DotGetter._(this.pick, this._palette);

  _DotGetter withPalette(GamePalette palette) => _DotGetter._(pick, palette);

  @override
  Widget build(BuildContext context) {
    final color = pick(_palette!);
    return _Dot(color: color);
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12, height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
    );
  }
}
