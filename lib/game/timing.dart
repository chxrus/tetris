class Timing {
  final Duration baseFall;          // базовый период падения
  final double softDropFactor;      // множитель ускорения
  final Duration lockDelay;         // задержка фиксации
  final Duration delayedAutoShift;  // DAS (когда начать повтор)
  final Duration autoRepeatRate;    // ARR (частота повтора)

  const Timing({
    required this.baseFall,
    required this.lockDelay,
    required this.delayedAutoShift,
    required this.autoRepeatRate,
    required this.softDropFactor,
  });

  Timing copyWith({
    Duration? baseFall,
    double? softDropFactor,
    Duration? lockDelay,
    Duration? delayedAutoShift,
    Duration? autoRepeatRate,
  }) => Timing(
    baseFall: baseFall ?? this.baseFall,
    softDropFactor: softDropFactor ?? this.softDropFactor,
    lockDelay: lockDelay ?? this.lockDelay,
    delayedAutoShift: delayedAutoShift ?? this.delayedAutoShift,
    autoRepeatRate: autoRepeatRate ?? this.autoRepeatRate,
  );

  static const defaults = Timing(
    baseFall: Duration(milliseconds: 600),
    lockDelay: Duration(milliseconds: 500),
    delayedAutoShift: Duration(milliseconds: 200),
    autoRepeatRate: Duration(milliseconds: 110),
    softDropFactor: 4.0,
  );
}
