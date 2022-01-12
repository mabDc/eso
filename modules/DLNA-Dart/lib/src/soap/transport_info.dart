class TransportInfo {
  String currentTransportState = TransportState.NO_MEDIA_PRESENT;
  String currentTransportStatus = TransportStatus.OK;
  String currentSpeed = '1';

  @override
  String toString() {
    return 'TransportInfo {currentTransportState: $currentTransportState,'
        ' currentTransportStatus: $currentTransportStatus, currentSpeed: $currentSpeed}';
  }
}

class TransportState {
  static const String STOPPED = 'STOPPED';
  static const String PLAYING = 'PLAYING';
  static const String TRANSITIONING = 'TRANSITIONING';
  static const String PAUSED_PLAYBACK = 'PAUSED_PLAYBACK';
  static const String PAUSED_RECORDING = 'PAUSED_RECORDING';
  static const String RECORDING = 'RECORDING';
  static const String NO_MEDIA_PRESENT = 'NO_MEDIA_PRESENT';
  static const String CUSTOM = 'CUSTOM';
}

class TransportStatus {
  static const String OK = 'OK';
  static const String ERROR_OCCURRED = 'ERROR_OCCURRED';
  static const String CUSTOM = 'CUSTOM';
}
