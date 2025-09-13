import 'package:tetris/model/tetromino.dart';

class RotationOffset {
  final int dx, dy;
  const RotationOffset(this.dx, this.dy);
}

int _key(int from, int to) => ((from & 3) * 4) + (to & 3);

// JLSTZ
const Map<int, List<RotationOffset>> _kicksJLSTZ = {
  0*4 + 1: [RotationOffset(0,0), RotationOffset(-1,0), RotationOffset(-1,1), RotationOffset(0,-2), RotationOffset(-1,-2)],
  1*4 + 2: [RotationOffset(0,0), RotationOffset(1,0),  RotationOffset(1,1),  RotationOffset(0,-2), RotationOffset(1,-2)],
  2*4 + 3: [RotationOffset(0,0), RotationOffset(1,0),  RotationOffset(1,-1), RotationOffset(0,2),  RotationOffset(1,2)],
  3*4 + 0: [RotationOffset(0,0), RotationOffset(-1,0), RotationOffset(-1,-1),RotationOffset(0,2),  RotationOffset(-1,2)],
  1*4 + 0: [RotationOffset(0,0), RotationOffset(1,0),  RotationOffset(1,-1), RotationOffset(0,2),  RotationOffset(1,2)],
  2*4 + 1: [RotationOffset(0,0), RotationOffset(-1,0), RotationOffset(-1,-1),RotationOffset(0,2),  RotationOffset(-1,2)],
  3*4 + 2: [RotationOffset(0,0), RotationOffset(-1,0), RotationOffset(-1,1), RotationOffset(0,-2), RotationOffset(-1,-2)],
  0*4 + 3: [RotationOffset(0,0), RotationOffset(1,0),  RotationOffset(1,1),  RotationOffset(0,-2), RotationOffset(1,-2)],
};

// I
const Map<int, List<RotationOffset>> _kicksI = {
  0*4 + 1: [RotationOffset(0,0), RotationOffset(-2,0), RotationOffset(1,0),  RotationOffset(-2,-1), RotationOffset(1,2)],
  1*4 + 2: [RotationOffset(0,0), RotationOffset(-1,0), RotationOffset(2,0),  RotationOffset(-1,2),  RotationOffset(2,-1)],
  2*4 + 3: [RotationOffset(0,0), RotationOffset(2,0),  RotationOffset(-1,0), RotationOffset(2,1),   RotationOffset(-1,-2)],
  3*4 + 0: [RotationOffset(0,0), RotationOffset(1,0),  RotationOffset(-2,0), RotationOffset(1,-2),  RotationOffset(-2,1)],
  1*4 + 0: [RotationOffset(0,0), RotationOffset(2,0),  RotationOffset(-1,0), RotationOffset(2,1),   RotationOffset(-1,-2)],
  2*4 + 1: [RotationOffset(0,0), RotationOffset(1,0),  RotationOffset(-2,0), RotationOffset(1,-2),  RotationOffset(-2,1)],
  3*4 + 2: [RotationOffset(0,0), RotationOffset(-2,0), RotationOffset(1,0),  RotationOffset(-2,-1), RotationOffset(1,2)],
  0*4 + 3: [RotationOffset(0,0), RotationOffset(-1,0), RotationOffset(2,0),  RotationOffset(-1,2),  RotationOffset(2,-1)],
};

List<RotationOffset> srsKicks(TetrominoType type, int from, int to) {
  final map = (type == TetrominoType.I) ? _kicksI : _kicksJLSTZ;
  return map[_key(from, to)] ?? const [RotationOffset(0, 0)];
}
