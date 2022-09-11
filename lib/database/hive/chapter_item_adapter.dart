import 'package:eso/database/chapter_item.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_type_id.dart';

T cast<T>(x, T v) => x is T ? x : v;

class ChapterItemAdapter extends TypeAdapter<ChapterItem> {
  @override
  ChapterItem read(BinaryReader reader) {
    final contentUrl = cast(reader.readString(), ""),
        cover = cast(reader.readString(), ""),
        name = cast(reader.readString(), ""),
        time = cast(reader.readString(), ""),
        url = cast(reader.readString(), "");
    return ChapterItem(
      contentUrl: contentUrl,
      cover: cover,
      name: name,
      time: time,
      url: url,
    );
  }

  @override
  int get typeId => chapterItemTypeId;

  @override
  void write(BinaryWriter writer, ChapterItem chapterItem) {
    writer.writeString(cast(chapterItem.contentUrl, ""));
    writer.writeString(cast(chapterItem.cover, ""));
    writer.writeString(cast(chapterItem.name, ""));
    writer.writeString(cast(chapterItem.time, ""));
    writer.writeString(cast(chapterItem.url, ""));
  }
}
