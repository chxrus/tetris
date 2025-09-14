import 'package:flutter/material.dart';
import 'package:tetris/model/tetromino_type.dart';

class GamePalette {
  final Color gameBackground;
  final Color boardBackground;
  final Color boardBorder;
  final Color boardGrid;
  final Color previewFrame;
  final Color hudTextPrimary;
  final Color hudTextSecondary;

  final Map<TetrominoType, Color> tetrominoColors;

  const GamePalette({
    required this.gameBackground,
    required this.boardBackground,
    required this.boardBorder,
    required this.boardGrid,
    required this.previewFrame,
    required this.hudTextPrimary,
    required this.hudTextSecondary,
    required this.tetrominoColors,
  });

  int colorOfTetromino(TetrominoType type) => tetrominoColors[type]!.toARGB32();

  GamePalette copyWith({
    Color? gameBackground,
    Color? boardBackground,
    Color? boardBorder,
    Color? boardGrid,
    Color? previewFrame,
    Color? hudTextPrimary,
    Color? hudTextSecondary,
    Map<TetrominoType, Color>? tetrominoColors,
  }) {
    return GamePalette(
      gameBackground: gameBackground ?? this.gameBackground,
      boardBackground: boardBackground ?? this.boardBackground,
      boardBorder: boardBorder ?? this.boardBorder,
      boardGrid: boardGrid ?? this.boardGrid,
      previewFrame: previewFrame ?? this.previewFrame,
      hudTextPrimary: hudTextPrimary ?? this.hudTextPrimary,
      hudTextSecondary: hudTextSecondary ?? this.hudTextSecondary,
      tetrominoColors: tetrominoColors ?? this.tetrominoColors,
    );
  }

  factory GamePalette.lightDefault() {
    return GamePalette(
      gameBackground: const Color(0xFFF5F7FB),
      boardBackground: Colors.white,
      boardBorder: const Color(0xFFE2E8F0),
      boardGrid: const Color(0xFFF1F5F9),
      previewFrame: const Color(0xFFE2E8F0),
      hudTextPrimary: const Color(0xFF0F172A),
      hudTextSecondary: const Color(0xFF64748B),
      tetrominoColors: const {
        TetrominoType.I: Color(0xFF00BCD4),
        TetrominoType.J: Color(0xFF1E88E5),
        TetrominoType.L: Color(0xFFF57C00),
        TetrominoType.O: Color(0xFFFBC02D),
        TetrominoType.S: Color(0xFF43A047),
        TetrominoType.T: Color(0xFF8E24AA),
        TetrominoType.Z: Color(0xFFE53935),
      },
    );
  }

  factory GamePalette.lightWarm() {
    return GamePalette(
      gameBackground: const Color(0xFFFAF7F2),
      boardBackground: const Color(0xFFFFFEFB),
      boardBorder: const Color(0xFFE8E2D9),
      boardGrid: const Color(0xFFF3EDE4),
      previewFrame: const Color(0xFFE8E2D9),
      hudTextPrimary: const Color(0xFF1F2937),
      hudTextSecondary: const Color(0xFF6B7280),
      tetrominoColors: const {
        TetrominoType.I: Color(0xFF00BCD4),
        TetrominoType.J: Color(0xFF1E88E5),
        TetrominoType.L: Color(0xFFF57C00),
        TetrominoType.O: Color(0xFFFBC02D),
        TetrominoType.S: Color(0xFF43A047),
        TetrominoType.T: Color(0xFF8E24AA),
        TetrominoType.Z: Color(0xFFE53935),
      },
    );
  }

  factory GamePalette.darkDefault() {
    return GamePalette(
      gameBackground: const Color(0xFF0B0E14),
      boardBackground: const Color(0xFF121723),
      boardBorder: const Color(0xFF2D3446),
      boardGrid: const Color(0xFF1E2533),
      previewFrame: const Color(0xFF2D3446),
      hudTextPrimary: const Color(0xFFE8ECF4),
      hudTextSecondary: const Color(0xFF9AA3B2),
      tetrominoColors: const {
        TetrominoType.I: Color(0xFF00BCD4),
        TetrominoType.J: Color(0xFF1E88E5),
        TetrominoType.L: Color(0xFFF57C00),
        TetrominoType.O: Color(0xFFFBC02D),
        TetrominoType.S: Color(0xFF43A047),
        TetrominoType.T: Color(0xFF8E24AA),
        TetrominoType.Z: Color(0xFFE53935),
      },
    );
  }
}
