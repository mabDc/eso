enum PlayMode {
  NORMAL,
  SHUFFLE,
  REPEAT_ONE,
  REPEAT_ALL,
  RANDOM,
  DIRECT_1,
  INTR
}

extension PlayModeName on PlayMode {
  String get name {
    if (this == null) {
      throw NullThrownError();
    }
    switch (this) {
      case PlayMode.NORMAL:
        return 'NORMAL';
      case PlayMode.SHUFFLE:
        return 'SHUFFLE';
      case PlayMode.REPEAT_ONE:
        return 'REPEAT_ONE';
      case PlayMode.REPEAT_ALL:
        return 'REPEAT_ALL';
      case PlayMode.RANDOM:
        return 'RANDOM';
      case PlayMode.DIRECT_1:
        return 'DIRECT_1';
      case PlayMode.INTR:
        return 'INTR';
      default:
        throw RangeError("enum PlayMode contains no value '$this'");
    }
  }
}
