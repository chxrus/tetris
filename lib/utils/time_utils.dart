double secs(Duration duration) => duration.inMicroseconds / 1e6;
Duration div(Duration duration, double factor) => Duration(microseconds: (duration.inMicroseconds / factor).round());