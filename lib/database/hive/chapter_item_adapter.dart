import 'package:eso/database/chapter_item.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_type_id.dart';

class ChapterItemAdapter extends TypeAdapter<ChapterItem> {
  @override
  ChapterItem read(BinaryReader reader) {
    final contentUrl = reader.readString(),
        cover = reader.readString(),
        name = reader.readString(),
        time = reader.readString(),
        url = reader.readString();
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
    writer.writeString(chapterItem.contentUrl);
    writer.writeString(chapterItem.cover);
    writer.writeString(chapterItem.name);
    writer.writeString(chapterItem.time);
    writer.writeString(chapterItem.url);
  }
}
