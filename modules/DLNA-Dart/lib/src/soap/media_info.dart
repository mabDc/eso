class MediaInfo {
  String currentURI = '';
  String currentURIMetaData = '';
  String nextURI = 'NOT_IMPLEMENTED';
  String nextURIMetaData = 'NOT_IMPLEMENTED';
  String numberOfTracks = '';
  String mediaDuration = '00:00:00';
  String playMedium = StorageMedium.NONE;
  String recordMedium = StorageMedium.NOT_IMPLEMENTED;
  String writeStatus = RecordMediumWriteStatus.NOT_IMPLEMENTED;

  @override
  String toString() {
    return 'MediaInfo {currentURI: $currentURI, currentURIMetaData: $currentURIMetaData,'
        ' nextURI: $nextURI, nextURIMetaData: $nextURIMetaData,'
        ' numberOfTracks: $numberOfTracks, mediaDuration: $mediaDuration,'
        ' playMedium: $playMedium, recordMedium: $recordMedium, writeStatus: $writeStatus}';
  }
}

class RecordMediumWriteStatus {
  static const String WRITABLE = 'WRITABLE';
  static const String PROTECTED = 'PROTECTED';
  static const String NOT_WRITABLE = 'NOT_WRITABLE';
  static const String UNKNOWN = 'UNKNOWN';
  static const String NOT_IMPLEMENTED = 'NOT_IMPLEMENTED';
}

class RecordQualityMode {
  static const EP = '0:EP';
  static const LP = '1:LP';
  static const SP = '2:SP';
  static const BASIC = '0:BASIC';
  static const MEDIUM = '1:MEDIUM';
  static const HIGH = '2:HIGH';
  static const NOT_IMPLEMENTED = 'NOT_IMPLEMENTED';
}

class StorageMedium {
  static const UNKNOWN = 'UNKNOWN';
  static const DV = 'DV';
  static const MINI_DV = 'MINI-DV';
  static const VHS = 'VHS';
  static const W_VHS = 'W-VHS';
  static const S_VHS = 'S-VHS';
  static const D_VHS = 'D-VHS';
  static const VHSC = 'VHSC';
  static const VIDEO8 = 'VIDEO8';
  static const HI8 = 'HI8';
  static const CD_ROM = 'CD-ROM';
  static const CD_DA = 'CD-DA';
  static const CD_R = 'CD-R';
  static const CD_RW = 'CD-RW';
  static const VIDEO_CD = 'VIDEO-CD';
  static const SACD = 'SACD';
  static const MD_AUDIO = 'M-AUDIO';
  static const MD_PICTURE = 'MD-PICTURE';
  static const DVD_ROM = 'DVD-ROM';
  static const DVD_VIDEO = 'DVD-VIDEO';
  static const DVD_R = 'DVD-R';
  static const DVD_PLUS_RW = 'DVD+RW';
  static const DVD_MINUS_RW = 'DVD-RW';
  static const DVD_RAM = 'DVD-RAM';
  static const DVD_AUDIO = 'DVD-AUDIO';
  static const DAT = 'DAT';
  static const LD = 'LD';
  static const HDD = 'HDD';
  static const MICRO_MV = 'MICRO_MV';
  static const NETWORK = 'NETWORK';
  static const NONE = 'NONE';
  static const NOT_IMPLEMENTED = 'NOT_IMPLEMENTED';
  static const VENDOR_SPECIFIC = 'VENDOR_SPECIFIC';
}
