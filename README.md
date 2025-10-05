# Tetris (Flutter + Flame)

A Tetris implementation built with **Flutter** and **Flame** (Dart).

## Features

* 7-bag piece generation
* Scoring, lines, and levels (fall speed increases with level)
* Soft (**S/↓**) and hard (**Space**) drop
* HUD with hints and next-piece preview
* Small visual effects (landing and line clear)
* **Theme presets** (Dark / Light / Warm) — switch in Pause → **Theme…**

## Controls

* Move: **A** / **←** left, **D** / **→** right
* Rotate: **Q** counter-clockwise, **E** / **↑** clockwise
* Drop: **S** / **↓** soft, **Space** hard
* Pause: **P** / **Esc**

## Run

```bash
flutter pub get
flutter run -d macos   # or windows, linux, chrome, ios, android
```

## Tech

* **Flutter** for the app and overlays
* **Flame** for game loop, components, camera, timers
* **Dart** for game logic

> Timing parameters (fall speed, delays, etc.) can be tweaked in `game/` settings.
