import 'package:tetris/theme/game_palette.dart';

class PalettePreset {
  final String name;
  final GamePalette palette;
  const PalettePreset(this.name, this.palette);
}

class Palettes {
  static GamePalette dark() => GamePalette.darkDefault();
  static GamePalette light() => GamePalette.lightDefault();
  static GamePalette warm() => GamePalette.lightWarm();

  static List<PalettePreset> all() => <PalettePreset>[
    PalettePreset('Dark', dark()),
    PalettePreset('Light', light()),
    PalettePreset('Warm', warm()),
  ];

  static String nameOf(GamePalette p) {
    for (final preset in all()) {
      if (_equalsPalette(preset.palette, p)) return preset.name;
    }
    return 'Custom';
  }

  static bool _equalsPalette(GamePalette a, GamePalette b) {
    return a.gameBackground.toARGB32() == b.gameBackground.toARGB32() &&
        a.boardBackground.toARGB32() == b.boardBackground.toARGB32() &&
        a.boardBorder.toARGB32() == b.boardBorder.toARGB32() &&
        a.boardGrid.toARGB32() == b.boardGrid.toARGB32() &&
        a.previewFrame.toARGB32() == b.previewFrame.toARGB32() &&
        a.hudTextPrimary.toARGB32() == b.hudTextPrimary.toARGB32() &&
        a.hudTextSecondary.toARGB32() == b.hudTextSecondary.toARGB32();
  }
}
