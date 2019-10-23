import '../global.dart';
import '../model/chapter_page_controller.dart';

class SearchItem {
  final String origin;
  final String originTag;
  final String cover;
  final String name;
  final String author;
  final String chapter;
  final String description;
  final String url;
  final RuleContentType ruleContentType;
  ChapterListStyle chapterListStyle;
  String durChapter;
  int durChapterIndex;
  int durContentIndex;

  SearchItem({
    this.origin,
    this.originTag,
    this.cover,
    this.name,
    this.author,
    this.chapter,
    this.description,
    this.url,
    this.ruleContentType,
    this.chapterListStyle,
    this.durChapter,
    this.durChapterIndex,
    this.durContentIndex,
  });
}
