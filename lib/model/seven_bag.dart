import 'dart:collection';
import 'dart:math';
import 'tetromino_type.dart';

/// Генератор 7-bag фигур
class SevenBag {
  final Random random;
  final int previewSize;

  List<TetrominoType> _bag = <TetrominoType>[];
  final Queue<TetrominoType> _queue = Queue<TetrominoType>();

  SevenBag({Random? random, this.previewSize = 1})
    : random = random ?? Random() {
    _refillBag();
    _fillQueueToPreviewSize();
  }

  TetrominoType get nextType => _queue.first;

  TetrominoType takeNext() {
    final TetrominoType next = _queue.removeFirst();
    _fillQueueToPreviewSize();
    return next;
  }

  List<TetrominoType> peekQueue() => _queue.toList(growable: false);

  void _refillBag() {
    _bag = TetrominoType.values.toList()..shuffle(random);
  }

  TetrominoType _drawFromBag() {
    if (_bag.isEmpty) _refillBag();
    return _bag.removeAt(0);
  }

  void _fillQueueToPreviewSize() {
    while (_queue.length < previewSize) {
      _queue.add(_drawFromBag());
    }
  }
}
