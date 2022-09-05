import 'package:eso/database/hive/chapter_item_adapter.dart';
import 'package:eso/database/search_item.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hive_type_id.dart';

class SearchItemAdapter extends TypeAdapter<SearchItem> {
  @override
  SearchItem read(BinaryReader reader) {
    final searchUrl = reader.readString(),
        chapterUrl = reader.readString(),
        id = reader.readInt(),
        origin = reader.readString(),
        originTag = reader.readString(),
        cover = reader.readString(),
        name = reader.readString(),
        author = reader.readString(),
        chapter = reader.readString(),
        description = reader.readString(),
        url = reader.readString(),
        ruleContentType = reader.readInt(),
        chapterListStyle = reader.readInt(),
        durChapter = reader.readString(),
        durChapterIndex = reader.readInt(),
        durContentIndex = reader.readInt(),
        chaptersCount = reader.readInt(),
        reverseChapter = reader.readBool(),
        tags = reader.readStringList(),
        createTime = reader.readInt(),
        updateTime = reader.readInt(),
        lastReadTime = reader.readInt(),
        group = reader.readString(),
        count = reader.readInt(),
        chapters =
            List.generate(count, (_) => ChapterItemAdapter().read(reader));

    return SearchItem.fromAdapter(
        searchUrl,
        chapterUrl,
        id,
        origin,
        originTag,
        cover,
        name,
        author,
        chapter,
        description,
        url,
        ruleContentType,
        chapterListStyle,
        durChapter,
        durChapterIndex,
        durContentIndex,
        chaptersCount,
        reverseChapter,
        tags,
        createTime,
        updateTime,
        lastReadTime,
        group,
        chapters);
  }

  @override
  int get typeId => searchItemTypeId;

  @override
  void write(BinaryWriter writer, SearchItem item) {
    writer.writeString(item.searchUrl);
    writer.writeString(item.chapterUrl);
    writer.writeInt(item.id);
    writer.writeString(item.origin);
    writer.writeString(item.originTag);
    writer.writeString(item.cover);
    writer.writeString(item.name);
    writer.writeString(item.author);
    writer.writeString(item.chapter);
    writer.writeString(item.description);
    writer.writeString(item.url);
    writer.writeInt(item.ruleContentType);
    writer.writeInt(item.chapterListStyle);
    writer.writeString(item.durChapter);
    writer.writeInt(item.durChapterIndex);
    writer.writeInt(item.durContentIndex);
    writer.writeInt(item.chaptersCount);
    writer.writeBool(item.reverseChapter);
    writer.writeStringList(item.tags);
    writer.writeInt(item.createTime);
    writer.writeInt(item.updateTime);
    writer.writeInt(item.lastReadTime);
    writer.writeString(item.group);

    writer.writeInt(item.chapters.length);
    for (var chapter in item.chapters) {
      ChapterItemAdapter().write(writer, chapter);
    }
  }
}
