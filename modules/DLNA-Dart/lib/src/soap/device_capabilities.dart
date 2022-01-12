class DeviceCapabilities {
  List<String> playMedia;
  List<String> recMedia;
  List<String> recQualityModes;

  @override
  String toString() {
    return 'DeviceCapabilities {playMedia: ${playMedia.length}, recMedia: ${recMedia.length}, '
        'recQualityModes: ${recQualityModes.length}';
  }
}
