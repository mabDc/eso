import 'lyric.dart';

class LyricUtil {
  /// 格式化歌词
  static List<Lyric> formatLyric(String lyricStr) {
    RegExp reg =
        RegExp(r"(?<=\[)\d{2}:\d{2}.\d{2,3}.*?(?=\[)|[^\[]+$", dotAll: true);

    var matches = reg.allMatches(lyricStr);
    var lyrics = matches.map((m) {
      var matchStr = m.group(0).replaceAll("\n", "");
      var symbolIndex = matchStr.indexOf("]");
      var time = matchStr.substring(0, symbolIndex);
      var lyric = matchStr.substring(symbolIndex + 1);
      var duration = lyricTimeToDuration(time);
      return Lyric(lyric, startTime: duration);
    }).toList();
    //移除所有空歌词
    lyrics.removeWhere((lyric) => lyric.lyric.trim().isEmpty);
    for (int i = 0; i < lyrics.length - 1; i++) {
      lyrics[i].endTime = lyrics[i + 1].startTime;
    }
    lyrics.last.endTime = Duration(hours: 200);
    return lyrics;
  }

  static Duration lyricTimeToDuration(String time) {
    int hourSeparatorIndex = time.indexOf(":");
    int minuteSeparatorIndex = time.indexOf(".");

    var milliseconds = time.substring(minuteSeparatorIndex + 1);
    var microseconds = 0;
    if(milliseconds.length>3){
      microseconds = int.parse(milliseconds.substring(3,milliseconds.length));
      milliseconds = milliseconds.substring(0,3);
    }
    return Duration(
      minutes: int.parse(
        time.substring(0, hourSeparatorIndex),
      ),
      seconds: int.parse(
          time.substring(hourSeparatorIndex + 1, minuteSeparatorIndex)),
      milliseconds: int.parse(milliseconds),
      microseconds: microseconds,
    );
  }
}
