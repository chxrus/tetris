import 'package:flutter/foundation.dart';

@immutable
class Timing {
  final Duration baseFall;          // базовый период падения
  final double softDropFactor;      // множитель ускорения soft drop
  final Duration lockDelay;         // задержка фиксации после приземления
  final Duration delayedAutoShift;  // DAS — задержка перед авто-повтором
  final Duration autoRepeatRate;    // ARR — период авто-повтора

  static const Timing defaults = Timing(
    baseFall: Duration(milliseconds: 600),
    lockDelay: Duration(milliseconds: 500),
    delayedAutoShift: Duration(milliseconds: 200),
    autoRepeatRate: Duration(milliseconds: 110),
    softDropFactor: 4.0,
  );
  
  const Timing({
    required this.baseFall,
    required this.softDropFactor,
    required this.lockDelay,
    required this.delayedAutoShift,
    required this.autoRepeatRate,
  });

  Timing copyWith({
    Duration? baseFall,
    double? softDropFactor,
    Duration? lockDelay,
    Duration? delayedAutoShift,
    Duration? autoRepeatRate,
  }) {
    return Timing(
      baseFall: baseFall ?? this.baseFall,
      softDropFactor: softDropFactor ?? this.softDropFactor,
      lockDelay: lockDelay ?? this.lockDelay,
      delayedAutoShift: delayedAutoShift ?? this.delayedAutoShift,
      autoRepeatRate: autoRepeatRate ?? this.autoRepeatRate,
    );
  }
}
