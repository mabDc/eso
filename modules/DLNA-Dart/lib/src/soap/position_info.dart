class PositionInfo {
  static const NOT_IMPLEMENTED = 'NOT_IMPLEMENTED';
  String title;
  String url;

  String track;
  String trackDuration = '00:00:00';
  String trackMetaData = NOT_IMPLEMENTED;
  String trackURI;
  String relTime = '00:00:00';
  String absTime = '00:00:00';
  String relCount;
  String absCount;

  int get trackDurationSeconds {
    return getTime(trackDuration);
  }

  int get trackElapsedSeconds {
    return getTime(relTime);
  }

  int get trackRemainingSeconds {
    return trackDurationSeconds - trackElapsedSeconds;
  }

  double get elapsedPercent {
    var elapsed = trackElapsedSeconds;
    var total = trackDurationSeconds;
    if (elapsed == 0 || total == 0) {
      return 0;
    } else {
      return elapsed * 100.0 / total;
    }
  }

  int getTime(String time) {
    switch (time) {
      case '':
      case '00:00:00':
      case NOT_IMPLEMENTED:
        {
          return 0;
        }
        break;
      default:
        {
          return fromTimeString(time);
        }
        break;
    }
  }

  int fromTimeString(String time) {
//    if (time.lastIndexOf('.') != -1) {
//      time = time.substring(0, time.lastIndexOf('.'));
//    }
    var split = time.split(':');
    if (split.length != 3) {
      return 0;
    }
    var timeInt = 0;
    try {
      timeInt = int.parse(split[0]) * 3600 +
          int.parse(split[1]) * 60 +
          int.parse(split[2]);
    } catch (ignore) {}
    return timeInt;
  }

  @override
  String toString() {
    return 'PositionInfo {track: $track, trackDuration: $trackDuration,'
        ' trackMetaData: $trackMetaData, trackURI: $trackURI, '
        'relTime: $relTime, absTime: $absTime, relCount: $relCount, absCount: $absCount}';
  }
}
