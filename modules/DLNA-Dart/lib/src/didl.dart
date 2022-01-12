class DIDLObject {
  String title;
  String url;
  String model;
  String protocol;
  bool refreshPosition = false;

  @override
  String toString() {
    return 'DIDLObject {title: $title, url: $url, model: $model, protocol: $protocol, refreshPosition: $refreshPosition}';
  }
}

class VideoObject extends DIDLObject {
  // common MIME types
  static const String VIDEO_MPEG = 'http-get:*:video/mpeg:*';
  static const String VIDEO_X_MS_WMV = 'http-get:*:video/x-ms-wmv:*';
  static const String VIDEO_X_MS_ASF = 'http-get:*:video/x-ms-asf:*';
  static const String VIDEO_X_MS_AVI = 'http-get:*:video/x-ms-avi:*';
  static const String VIDEO_MSVIDEO = 'http-get:*:video/x-msvideo:*';
  static const String VIDEO_MPEG4 = 'http-get:*:video/mpeg4:*';
  static const String VIDEO_AVI = 'http-get:*:video/avi:*';
  static const String VIDEO_H264 = 'http-get:*:video/h264:*';
  static const String VIDEO_MP4 = 'http-get:*:video/mp4:*';
  static const String VIDEO_MP4_ES = 'http-get:*:video/mp4v-es:*';
  static const String VIDEO_3GPP = 'http-get:*:video/3gpp:*';
  static const String VIDEO_FLV = 'http-get:*:video/flv:*';
  static const String VIDEO_X_MATROSKA = 'http-get:*:video/x-matroska:*';
  static const String VIDEO_QUICKTIME = 'http-get:*:video/quicktime:*';

  VideoObject(String title, String url, String protocol) {
    this.title = title;
    this.url = url;
    this.protocol = protocol;
  }

  @override
  String toString() {
    return 'Video ${super.toString()}';
  }
}

class AudioObject extends DIDLObject {
  static const String AUDIO_MPEGURL = 'http-get:*:audio/mpegurl:*';
  static const String AUDIO_WAV = 'http-get:*:audio/wav:*';
  static const String AUDIO_L16 = 'http-get:*:audio/l16:AUDIO*';
  static const String AUDIO_MP3 = 'http-get:*:audio/mp3:*';
  static const String AUDIO_MPEG = 'http-get:*:audio/mpeg:*';
  static const String AUDIO_X_MS_WMA = 'http-get:*:audio/x-ms-wma:*';
  static const String AUDIO_WMA = 'http-get:*:audio/wma:*';
  static const String AUDIO_VND_DLNA_ADTS = 'http-get:*:audio/vnd.dlna.adts:*';
  static const String AUDIO_MP4 = 'http-get:*:audio/mp4:*';
  static const String AUDIO_X_AIFF = 'http-get:*:audio/x-aiff:*';
  static const String AUDIO_X_FLAC = 'http-get:*:audio/x-flac:*';
  static const String AUDIO_X_APE = 'http-get:*:audio/x-ape:*';
  static const String AUDIO_X_MATROSKA = 'http-get:*:audio/x-matroska:*';

  AudioObject(String title, String url, String protocol) {
    this.title = title;
    this.url = url;
    this.protocol = protocol;
  }

  @override
  String toString() {
    return 'AudioObject ${super.toString()}';
  }
}

class ImageObject extends DIDLObject {
  static const String IMAGE_JPEG = 'http-get:*:image/jpeg:*';
  static const String IMAGE_PNG = 'http-get:*:image/png:*';
  static const String IMAGE_TIFF = 'http-get:*:image/tiff:*';
  static const String IMAGE_GIF = 'http-get:*:image/gif:*';

  ImageObject(String title, String url, String protocol) {
    this.title = title;
    this.url = url;
    this.protocol = protocol;
  }

  @override
  String toString() {
    return 'ImageObject ${super.toString()}';
  }
}
