extension ListHelper<T> on List<T> {
  void addIfNotExist(T e) {
    if (!contains(e)) add(e);
  }

  void addAllIfNotExist(Iterable<T> e) {
    for (T item in e) {
      addIfNotExist(item);
    }
  }
}
