import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/api.dart';
import '../../database/chapter_item.dart';
import '../../database/search_item.dart';

import 'package:html/parser.dart' show parse;

class Qidian implements API {
  @override
  String get origin => '起点';

  @override
  String get originTag => 'Qidian';

  @override
  int get ruleContentType => API.NOVEL;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    return parse(res.body)
        .querySelectorAll('.all-img-list li,#result-list li,#limit-list li')
        .map((item) => SearchItem(
              tags: <String>[],
              api: this,
              cover:
                  'https:${item.querySelector('.book-img-box img').attributes["src"]}',
              name: '${item.querySelector('h4 a').text}',
              author: '${item.querySelector('.author a').text}',
              chapter: '${item.querySelector('.update').text}',
              description: '${item.querySelector('.intro').text}',
              url:
                  'https://druid.if.qidian.com/argus/api/v1/chapterlist/chapterlist?bookId=${item.querySelector('h4 a').attributes["data-bid"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    String url = 'https://www.qidian.com/${params["免费"].value}';
    if (params["免费"].name == '限时免费') {
      return commonParse(url);
    }
    String query = params.entries
        .where((entry) => entry.value.value != '' && entry.key != '免费')
        .map((entry) => entry.value.value)
        .join('&');
    return commonParse("$url?$query&page=$page");
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse("https://www.qidian.com/search?kw=$query&page=$page");
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final bookId = url.substring(
        'https://druid.if.qidian.com/argus/api/v1/chapterlist/chapterlist?bookId='
            .length);
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
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap("免费", <DiscoverPair>[
        DiscoverPair("全部", "all"),
        DiscoverPair("限时免费", "free"),
        DiscoverPair("免费作品", "free/all"),
      ]),
      DiscoverMap("分类", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("玄幻", "chanId=21"),
        DiscoverPair("东方玄幻", "chanId=21&subCateId=8"),
        DiscoverPair("异世大陆", "chanId=21&subCateId=73"),
        DiscoverPair("王朝争霸", "chanId=21&subCateId=58"),
        DiscoverPair("高武世界", "chanId=21&subCateId=78"),
        DiscoverPair("奇幻", "chanId=1"),
        DiscoverPair("现代魔法", "chanId=1&subCateId=38"),
        DiscoverPair("剑与魔法", "chanId=1&subCateId=62"),
        DiscoverPair("史诗奇幻", "chanId=1&subCateId=201"),
        DiscoverPair("黑暗幻想", "chanId=1&subCateId=202"),
        DiscoverPair("历史神话", "chanId=1&subCateId=20092"),
        DiscoverPair("另类幻想", "chanId=1&subCateId=20093"),
        DiscoverPair("武侠", "chanId=2"),
        DiscoverPair("传统武侠", "chanId=2&subCateId=5"),
        DiscoverPair("武侠幻想", "chanId=2&subCateId=30"),
        DiscoverPair("国术无双", "chanId=2&subCateId=206"),
        DiscoverPair("古武未来", "chanId=2&subCateId=20099"),
        DiscoverPair("武侠同人", "chanId=2&subCateId=20100"),
        DiscoverPair("仙侠", "chanId=22"),
        DiscoverPair("修真文明", "chanId=22&subCateId=18"),
        DiscoverPair("幻想修仙", "chanId=22&subCateId=44"),
        DiscoverPair("现代修真", "chanId=22&subCateId=64"),
        DiscoverPair("神话修真", "chanId=22&subCateId=207"),
        DiscoverPair("古典仙侠", "chanId=22&subCateId=20101"),
        DiscoverPair("都市", "chanId=4"),
        DiscoverPair("都市生活", "chanId=4&subCateId=12"),
        DiscoverPair("都市异能", "chanId=4&subCateId=16"),
        DiscoverPair("异术超能", "chanId=4&subCateId=74"),
        DiscoverPair("青春校园", "chanId=4&subCateId=130"),
        DiscoverPair("娱乐明星", "chanId=4&subCateId=151"),
        DiscoverPair("商战职场", "chanId=4&subCateId=153"),
        DiscoverPair("现实", "chanId=15"),
        DiscoverPair("社会乡土", "chanId=15&subCateId=20104"),
        DiscoverPair("生活时尚", "chanId=15&subCateId=20105"),
        DiscoverPair("文学艺术", "chanId=15&subCateId=20106"),
        DiscoverPair("成功励志", "chanId=15&subCateId=20107"),
        DiscoverPair("青春文学", "chanId=15&subCateId=20108"),
        DiscoverPair("爱情婚姻", "chanId=15&subCateId=6"),
        DiscoverPair("现实百态", "chanId=15&subCateId=209"),
        DiscoverPair("军事", "chanId=6"),
        DiscoverPair("军旅生涯", "chanId=6&subCateId=54"),
        DiscoverPair("军事战争", "chanId=6&subCateId=65"),
        DiscoverPair("战争幻想", "chanId=6&subCateId=80"),
        DiscoverPair("抗战烽火", "chanId=6&subCateId=230"),
        DiscoverPair("谍战特工", "chanId=6&subCateId=231"),
        DiscoverPair("历史", "chanId=5"),
        DiscoverPair("架空历史", "chanId=5&subCateId=22"),
        DiscoverPair("秦汉三国", "chanId=5&subCateId=48"),
        DiscoverPair("上古先秦", "chanId=5&subCateId=220"),
        DiscoverPair("历史传记", "chanId=5&subCateId=32"),
        DiscoverPair("两晋隋唐", "chanId=5&subCateId=222"),
        DiscoverPair("五代十国", "chanId=5&subCateId=223"),
        DiscoverPair("两宋元明", "chanId=5&subCateId=224"),
        DiscoverPair("清史民国", "chanId=5&subCateId=225"),
        DiscoverPair("外国历史", "chanId=5&subCateId=226"),
        DiscoverPair("民间传说", "chanId=5&subCateId=20094"),
        DiscoverPair("游戏", "chanId=7"),
        DiscoverPair("电子竞技", "chanId=7&subCateId=7"),
        DiscoverPair("虚拟网游", "chanId=7&subCateId=70"),
        DiscoverPair("游戏异界", "chanId=7&subCateId=240"),
        DiscoverPair("游戏系统", "chanId=7&subCateId=20102"),
        DiscoverPair("游戏主播", "chanId=7&subCateId=20103"),
        DiscoverPair("体育", "chanId=8"),
        DiscoverPair("篮球运动", "chanId=8&subCateId=28"),
        DiscoverPair("体育赛事", "chanId=8&subCateId=55"),
        DiscoverPair("足球运动", "chanId=8&subCateId=82"),
        DiscoverPair("科幻", "chanId=9"),
        DiscoverPair("古武机甲", "chanId=9&subCateId=21"),
        DiscoverPair("未来世界", "chanId=9&subCateId=25"),
        DiscoverPair("星际文明", "chanId=9&subCateId=68"),
        DiscoverPair("超级科技", "chanId=9&subCateId=250"),
        DiscoverPair("时空穿梭", "chanId=9&subCateId=251"),
        DiscoverPair("进化变异", "chanId=9&subCateId=252"),
        DiscoverPair("末世危机", "chanId=9&subCateId=253"),
        DiscoverPair("悬疑", "chanId=10"),
        DiscoverPair("诡秘悬疑", "chanId=10&subCateId=26"),
        DiscoverPair("奇妙世界", "chanId=10&subCateId=35"),
        DiscoverPair("侦探推理", "chanId=10&subCateId=57"),
        DiscoverPair("探险生存", "chanId=10&subCateId=260"),
        DiscoverPair("古今传奇", "chanId=10&subCateId=20095"),
        DiscoverPair("轻小说", "chanId=12"),
        DiscoverPair("原生幻想", "chanId=12&subCateId=60"),
        DiscoverPair("青春日常", "chanId=12&subCateId=66"),
        DiscoverPair("衍生同人", "chanId=12&subCateId=281"),
        DiscoverPair("搞笑吐槽", "chanId=12&subCateId=282"),
        DiscoverPair("短篇", "chanId=20076"),
        DiscoverPair("诗歌散文", "chanId=20076&subCateId=20097"),
        DiscoverPair("人物传记", "chanId=20076&subCateId=20098"),
        DiscoverPair("影视剧本", "chanId=20076&subCateId=20075"),
        DiscoverPair("评论文集", "chanId=20076&subCateId=20077"),
        DiscoverPair("生活随笔", "chanId=20076&subCateId=20078"),
        DiscoverPair("美文游记", "chanId=20076&subCateId=20079"),
        DiscoverPair("短篇小说", "chanId=20076&subCateId=20096"),
      ]),
      DiscoverMap("状态", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("连载", "action=0"),
        DiscoverPair("完本", "action=1"),
      ]),
      DiscoverMap("属性", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("免费", "vip=0"),
        DiscoverPair("VIP", "vip=1"),
      ]),
      DiscoverMap("字数", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("30万字以下", "size=1"),
        DiscoverPair("30-50万字", "size=2"),
        DiscoverPair("50-100万字", "size=3"),
        DiscoverPair("100-200万字", "size=4"),
        DiscoverPair("200万字以上", "size=5"),
      ]),
      DiscoverMap("品质", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("签约作品", "sign=1"),
        DiscoverPair("精品小说", "sign=2"),
      ]),
      DiscoverMap("更新时间", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("三日内", "update=1"),
        DiscoverPair("七日内", "update=2"),
        DiscoverPair("半月内", "update=3"),
        DiscoverPair("一月内", "update=4"),
      ]),
      DiscoverMap("标签", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("豪门", "tag=豪门"),
        DiscoverPair("孤儿", "tag=孤儿"),
        DiscoverPair("盗贼", "tag=盗贼"),
        DiscoverPair("特工", "tag=特工"),
        DiscoverPair("黑客", "tag=黑客"),
        DiscoverPair("明星", "tag=明星"),
        DiscoverPair("特种兵", "tag=特种兵"),
        DiscoverPair("杀手", "tag=杀手"),
        DiscoverPair("老师", "tag=老师"),
        DiscoverPair("学生", "tag=学生"),
        DiscoverPair("胖子", "tag=胖子"),
        DiscoverPair("宠物", "tag=宠物"),
        DiscoverPair("蜀山", "tag=蜀山"),
        DiscoverPair("魔王附体", "tag=魔王附体"),
        DiscoverPair("LOL", "tag=LOL"),
        DiscoverPair("废材流", "tag=废材流"),
        DiscoverPair("护短", "tag=护短"),
        DiscoverPair("卡片", "tag=卡片"),
        DiscoverPair("手游", "tag=手游"),
        DiscoverPair("法师", "tag=法师"),
        DiscoverPair("医生", "tag=医生"),
        DiscoverPair("感情", "tag=感情"),
        DiscoverPair("鉴宝", "tag=鉴宝"),
        DiscoverPair("亡灵", "tag=亡灵"),
        DiscoverPair("职场", "tag=职场"),
        DiscoverPair("吸血鬼", "tag=吸血鬼"),
        DiscoverPair("龙", "tag=龙"),
        DiscoverPair("西游", "tag=西游"),
        DiscoverPair("鬼怪", "tag=鬼怪"),
        DiscoverPair("阵法", "tag=阵法"),
        DiscoverPair("魔兽", "tag=魔兽"),
        DiscoverPair("勇猛", "tag=勇猛"),
        DiscoverPair("玄学", "tag=玄学"),
        DiscoverPair("群穿", "tag=群穿"),
        DiscoverPair("丹药", "tag=丹药"),
        DiscoverPair("练功流", "tag=练功流"),
        DiscoverPair("召唤流", "tag=召唤流"),
        DiscoverPair("恶搞", "tag=恶搞"),
        DiscoverPair("爆笑", "tag=爆笑"),
        DiscoverPair("轻松", "tag=轻松"),
        DiscoverPair("冷酷", "tag=冷酷"),
        DiscoverPair("腹黑", "tag=腹黑"),
        DiscoverPair("阳光", "tag=阳光"),
        DiscoverPair("狡猾", "tag=狡猾"),
        DiscoverPair("机智", "tag=机智"),
        DiscoverPair("猥琐", "tag=猥琐"),
        DiscoverPair("嚣张", "tag=嚣张"),
        DiscoverPair("淡定", "tag=淡定"),
        DiscoverPair("僵尸", "tag=僵尸"),
        DiscoverPair("丧尸", "tag=丧尸"),
        DiscoverPair("盗墓", "tag=盗墓"),
        DiscoverPair("随身流", "tag=随身流"),
        DiscoverPair("软饭流", "tag=软饭流"),
        DiscoverPair("无敌文", "tag=无敌文"),
        DiscoverPair("异兽流", "tag=异兽流"),
        DiscoverPair("系统流", "tag=系统流"),
        DiscoverPair("洪荒流", "tag=洪荒流"),
        DiscoverPair("学院流", "tag=学院流"),
        DiscoverPair("位面", "tag=位面"),
        DiscoverPair("铁血", "tag=铁血"),
        DiscoverPair("励志", "tag=励志"),
        DiscoverPair("坚毅", "tag=坚毅"),
        DiscoverPair("变身", "tag=变身"),
        DiscoverPair("强者回归", "tag=强者回归"),
        DiscoverPair("赚钱", "tag=赚钱"),
        DiscoverPair("争霸流", "tag=争霸流"),
        DiscoverPair("种田文", "tag=种田文"),
        DiscoverPair("宅男", "tag=宅男"),
        DiscoverPair("无限流", "tag=无限流"),
        DiscoverPair("技术流", "tag=技术流"),
        DiscoverPair("凡人流", "tag=凡人流"),
        DiscoverPair("热血", "tag=热血"),
        DiscoverPair("重生", "tag=重生"),
        DiscoverPair("穿越", "tag=穿越"),
      ]),
    ];
  }
}
