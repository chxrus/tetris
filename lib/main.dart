import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:tetris/game/tetris_game.dart';

void main() {
  final world = World();

  final camera = CameraComponent(
    world: world,
  )..viewfinder.anchor = Anchor.topLeft;

  final game = TetrisGame()
    ..world = world
    ..camera = camera;
  runApp(GameWidget(game: game));
}
