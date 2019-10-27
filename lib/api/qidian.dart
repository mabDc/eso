import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'package:html/parser.dart' show parse;

class Qidian implements API {
  @override
  String get origin => '起点';

  @override
  String get originTag => 'Qidian';

  @override
  RuleContentType get ruleContentType => RuleContentType.NOVEL;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    return parse(res.body)
        .querySelectorAll('.all-img-list li,#limit-list li')
        .map((item) => SearchItem(
              api: this,
              cover:
                  'https:${item.querySelector('.book-img-box img').attributes["src"]}',
              name: '${item.querySelector('h4 a').text}',
              author: '${item.querySelector('.author a').text}',
              chapter: '${item.querySelector('.update').text}',
              description: '${item.querySelector('.intro').text}',
              url: '${item.querySelector('h4 a').attributes["data-bid"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(
      String query, int page, int pageSize) async {
    if (query == '') {
      query = discoverMap().values.first;
    }
    return commonParse("https://www.qidian.com/$query&page=$page");
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse("https://www.qidian.com/search?kw=$query&page=$page");
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final bookId = url;
    final res = await http.get(
        'https://druid.if.qidian.com/argus/api/v1/chapterlist/chapterlist?bookId=$bookId');
    final json = jsonDecode(res.body);
    return (json["Data"]["Chapters"] as List).skip(1).map((chapter) {
      final time = DateTime.fromMillisecondsSinceEpoch(chapter["T"]);
      return ChapterItem(
        cover: null,
        name: '${chapter["V"] == 1 ? "🔒" : ""}${chapter["N"]}',
        time: '$time'.trim().substring(0, 16),
        url: 'https://vipreader.qidian.com/chapter/$bookId/${chapter["C"]}',
      );
    }).toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    return parse(res.body)
        .querySelectorAll('.read-content p')
        .map((p) => p.text)
        .toList();
  }

  @override
  Map<String, String> discoverMap() {
    return {
      "全部": "all?",
      "限时免费":"free?",
      "玄幻": "all?chanId=21",
      "东方玄幻": "all?chanId=21&subCateId=8",
      "异世大陆": "all?chanId=21&subCateId=73",
      "王朝争霸": "all?chanId=21&subCateId=58",
      "高武世界": "all?chanId=21&subCateId=78",
      "奇幻": "all?chanId=1",
      "现代魔法": "all?chanId=1&subCateId=38",
      "剑与魔法": "all?chanId=1&subCateId=62",
      "史诗奇幻": "all?chanId=1&subCateId=201",
      "黑暗幻想": "all?chanId=1&subCateId=202",
      "历史神话": "all?chanId=1&subCateId=20092",
      "另类幻想": "all?chanId=1&subCateId=20093",
      "武侠": "all?chanId=2",
      "传统武侠": "all?chanId=2&subCateId=5",
      "武侠幻想": "all?chanId=2&subCateId=30",
      "国术无双": "all?chanId=2&subCateId=206",
      "古武未来": "all?chanId=2&subCateId=20099",
      "武侠同人": "all?chanId=2&subCateId=20100",
      "仙侠": "all?chanId=22",
      "修真文明": "all?chanId=22&subCateId=18",
      "幻想修仙": "all?chanId=22&subCateId=44",
      "现代修真": "all?chanId=22&subCateId=64",
      "神话修真": "all?chanId=22&subCateId=207",
      "古典仙侠": "all?chanId=22&subCateId=20101",
      "都市": "all?chanId=4",
      "都市生活": "all?chanId=4&subCateId=12",
      "都市异能": "all?chanId=4&subCateId=16",
      "异术超能": "all?chanId=4&subCateId=74",
      "青春校园": "all?chanId=4&subCateId=130",
      "娱乐明星": "all?chanId=4&subCateId=151",
      "商战职场": "all?chanId=4&subCateId=153",
      "现实": "all?chanId=15",
      "社会乡土": "all?chanId=15&subCateId=20104",
      "生活时尚": "all?chanId=15&subCateId=20105",
      "文学艺术": "all?chanId=15&subCateId=20106",
      "成功励志": "all?chanId=15&subCateId=20107",
      "青春文学": "all?chanId=15&subCateId=20108",
      "爱情婚姻": "all?chanId=15&subCateId=6",
      "现实百态": "all?chanId=15&subCateId=209",
      "军事": "all?chanId=6",
      "军旅生涯": "all?chanId=6&subCateId=54",
      "军事战争": "all?chanId=6&subCateId=65",
      "战争幻想": "all?chanId=6&subCateId=80",
      "抗战烽火": "all?chanId=6&subCateId=230",
      "谍战特工": "all?chanId=6&subCateId=231",
      "历史": "all?chanId=5",
      "架空历史": "all?chanId=5&subCateId=22",
      "秦汉三国": "all?chanId=5&subCateId=48",
      "上古先秦": "all?chanId=5&subCateId=220",
      "历史传记": "all?chanId=5&subCateId=32",
      "两晋隋唐": "all?chanId=5&subCateId=222",
      "五代十国": "all?chanId=5&subCateId=223",
      "两宋元明": "all?chanId=5&subCateId=224",
      "清史民国": "all?chanId=5&subCateId=225",
      "外国历史": "all?chanId=5&subCateId=226",
      "民间传说": "all?chanId=5&subCateId=20094",
      "游戏": "all?chanId=7",
      "电子竞技": "all?chanId=7&subCateId=7",
      "虚拟网游": "all?chanId=7&subCateId=70",
      "游戏异界": "all?chanId=7&subCateId=240",
      "游戏系统": "all?chanId=7&subCateId=20102",
      "游戏主播": "all?chanId=7&subCateId=20103",
      "体育": "all?chanId=8",
      "篮球运动": "all?chanId=8&subCateId=28",
      "体育赛事": "all?chanId=8&subCateId=55",
      "足球运动": "all?chanId=8&subCateId=82",
      "科幻": "all?chanId=9",
      "古武机甲": "all?chanId=9&subCateId=21",
      "未来世界": "all?chanId=9&subCateId=25",
      "星际文明": "all?chanId=9&subCateId=68",
      "超级科技": "all?chanId=9&subCateId=250",
      "时空穿梭": "all?chanId=9&subCateId=251",
      "进化变异": "all?chanId=9&subCateId=252",
      "末世危机": "all?chanId=9&subCateId=253",
      "悬疑": "all?chanId=10",
      "诡秘悬疑": "all?chanId=10&subCateId=26",
      "奇妙世界": "all?chanId=10&subCateId=35",
      "侦探推理": "all?chanId=10&subCateId=57",
      "探险生存": "all?chanId=10&subCateId=260",
      "古今传奇": "all?chanId=10&subCateId=20095",
      "轻小说": "all?chanId=12",
      "原生幻想": "all?chanId=12&subCateId=60",
      "青春日常": "all?chanId=12&subCateId=66",
      "衍生同人": "all?chanId=12&subCateId=281",
      "搞笑吐槽": "all?chanId=12&subCateId=282",
      "短篇": "all?chanId=20076",
      "诗歌散文": "all?chanId=20076&subCateId=20097",
      "人物传记": "all?chanId=20076&subCateId=20098",
      "影视剧本": "all?chanId=20076&subCateId=20075",
      "评论文集": "all?chanId=20076&subCateId=20077",
      "生活随笔": "all?chanId=20076&subCateId=20078",
      "美文游记": "all?chanId=20076&subCateId=20079",
      "短篇小说": "all?chanId=20076&subCateId=20096",
    };
  }
}
