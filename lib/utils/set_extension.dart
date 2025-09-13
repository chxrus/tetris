extension SetExtension<E> on Set<E> {
  bool containsAny(Iterable<Object?> other) =>
      other.whereType<E>().any(contains);
}
