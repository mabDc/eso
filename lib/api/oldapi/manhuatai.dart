import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';

import 'package:http/http.dart' as http;

class Manhuatai implements API {
  @override
  String get origin => '漫画台';

  @override
  String get originTag => 'Manhuatai';

  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(res.body);
    return (json["data"] as List).map((item) {
      final id = item["comic_id"];
      return SearchItem(
          tags: <String>[],
          api: this,
          cover: 'http://image.mhxk.com/mh/$id.jpg',
          name: item["comic_name"],
          author: '',
          chapter: '',
          description: '${item["comic_type"]}'
              .replaceAll(RegExp('^\\w+,|\\|\\w+,'), ' '),
          url:
              'http://getcomicinfo-globalapi.yyhao.com/app_api/v5/getcomicinfo_body/?comic_id=$id');
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    final query = params.values
        .where((pair) => pair.value != '')
        .map((pair) => pair.value)
        .join('&');
    return commonParse(
        'http://getcomicinfo-globalapi.yyhao.com/app_api/v5/getsortlist/?$query&page=$page');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        'http://getcomicinfo-globalapi.yyhao.com/app_api/v5/getsortlist/?search_key=$query&page=$page');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final json = jsonDecode(res.body);
    final chapters = json["comic_chapter"] as List;
    final list = List<ChapterItem>(chapters.length);
    for (int i = 0; i < chapters.length; i++) {
      final chapter = chapters[chapters.length - i - 1];
      final time =
          DateTime.fromMillisecondsSinceEpoch(chapter["create_date"] * 1000);
      final chapterImage = chapter["chapter_image"];
      final rule =
          '${chapterImage["high"] ?? chapterImage["middle"] ?? chapterImage["low"]}'
              .split('\$\$');
      final domain = 'https://mhpic.${chapter["chapter_domain"]}';
      final startNum = '${chapter["start_num"]}';
      list[i] = ChapterItem(
        cover: '$domain${rule[0]}$startNum${rule[1]}',
        name:
            '${chapter["isbuy"] == 1 ? '💰' : ''}${chapter["islock"] == 1 ? '🔒' : ''}${chapter["chapter_name"]}',
        time: '$time'.trim().substring(0, 16),
        url: '$domain${rule[0]}?$startNum&${chapter["end_num"]}&${rule[1]}',
      );
    }
    return list;
  }

  @override
  Future<List<String>> content(String url) async {
    final urls = url.split('?');
    final query = urls[1].split('&');
    final startNum = int.parse(query[0]);
    final len = int.parse(query[1]) - startNum + 1;
    List<String> images = List<String>(len);
    for (int i = 0; i < len; i++) {
      images[i] = '${urls[0]}${i + 1}${query[2]}';
    }
    return images;
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap('排序', <DiscoverPair>[
        DiscoverPair('热度', 'orderby=click'),
        DiscoverPair('收藏', 'orderby=shoucang'),
        DiscoverPair('更新', 'orderby=date'),
      ]),
      DiscoverMap('类型', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair("连载", "comic_sort=lianzai"),
        DiscoverPair("完结", "comic_sort=wanjie"),
        DiscoverPair("热血", "comic_sort=rexue"),
        DiscoverPair("机战", "comic_sort=jizhan"),
        DiscoverPair("运动", "comic_sort=yundong"),
        DiscoverPair("推理", "comic_sort=tuili"),
        DiscoverPair("冒险", "comic_sort=maoxian"),
        DiscoverPair("搞笑", "comic_sort=gaoxiao"),
        DiscoverPair("战争", "comic_sort=zhanzhen"),
        DiscoverPair("神魔", "comic_sort=shenmo"),
        DiscoverPair("忍者", "comic_sort=renzhe"),
        DiscoverPair("竞技", "comic_sort=jingji"),
        DiscoverPair("悬疑", "comic_sort=xuanyi"),
        DiscoverPair("社会", "comic_sort=shehui"),
        DiscoverPair("恋爱", "comic_sort=lianai"),
        DiscoverPair("宠物", "comic_sort=chongwu"),
        DiscoverPair("吸血", "comic_sort=xixue"),
        DiscoverPair("萝莉", "comic_sort=luoli"),
        DiscoverPair("后宫", "comic_sort=hougong"),
        DiscoverPair("御姐", "comic_sort=yujie"),
        DiscoverPair("霸总", "comic_sort=bazong"),
        DiscoverPair("玄幻", "comic_sort=xuanhuan"),
        DiscoverPair("古风", "comic_sort=gufeng"),
        DiscoverPair("历史", "comic_sort=lishi"),
        DiscoverPair("漫改", "comic_sort=mangai"),
        DiscoverPair("游戏", "comic_sort=youxi"),
        DiscoverPair("穿越", "comic_sort=chuanyue"),
        DiscoverPair("恐怖", "comic_sort=kongbu"),
        DiscoverPair("真人", "comic_sort=zhenren"),
        DiscoverPair("科幻", "comic_sort=kehuan"),
        DiscoverPair("都市", "comic_sort=dushi"),
        DiscoverPair("武侠", "comic_sort=wuxia"),
        DiscoverPair("修真", "comic_sort=xiuzhen"),
        DiscoverPair("生活", "comic_sort=shenghuo"),
        DiscoverPair("动作", "comic_sort=dongzuo"),
        DiscoverPair("大陆", "comic_sort=dalu"),
        DiscoverPair("日本", "comic_sort=riben"),
        DiscoverPair("港台", "comic_sort=gangtai"),
        DiscoverPair("欧美", "comic_sort=oumei"),
        DiscoverPair("韩国", "comic_sort=os"),
        DiscoverPair("全彩", "comic_sort=quancai"),
        DiscoverPair("黑白", "comic_sort=heibai"),
        DiscoverPair("知音漫客", "comic_sort=zhiyinmanke"),
        DiscoverPair("神漫", "comic_sort=shenman"),
        DiscoverPair("飒漫画", "comic_sort=samanhua"),
        DiscoverPair("飒漫乐画", "comic_sort=samanlehua"),
        DiscoverPair("风炫漫画", "comic_sort=fengxuanmanhua"),
        DiscoverPair("爱漫画", "comic_sort=aimanhua"),
        DiscoverPair("漫画周刊", "comic_sort=manhuazhoukan"),
        DiscoverPair("漫客栈", "comic_sort=mankezhan"),
        DiscoverPair("漫画派对", "comic_sort=manhuapaidui"),
        DiscoverPair("漫画世界", "comic_sort=manhuashijie"),
        DiscoverPair("漫画会", "comic_sort=manhuahui"),
        DiscoverPair("中国卡通", "comic_sort=zhongguokatong"),
        DiscoverPair("漫画show", "comic_sort=manhuashow"),
        DiscoverPair("漫友", "comic_sort=manyou"),
        DiscoverPair("乐漫", "comic_sort=leman"),
        DiscoverPair("怪兽漫画", "comic_sort=guaishoumanhua"),
        DiscoverPair("淘漫画", "comic_sort=taomanhua"),
        DiscoverPair("极漫", "comic_sort=jiman"),
        DiscoverPair("漫王", "comic_sort=manwang"),
        DiscoverPair("壹周漫画", "comic_sort=yizhoumanhua"),
        DiscoverPair("星漫", "comic_sort=xingman"),
        DiscoverPair("看漫画", "comic_sort=kanmanhua"),
        DiscoverPair("精品", "comic_sort=jingpin"),
        DiscoverPair("小说改编", "comic_sort=xiaoshuo"),
        DiscoverPair("内涵", "comic_sort=baozou"),
        DiscoverPair("杂志", "comic_sort=zazhi"),
        DiscoverPair("日更", "comic_sort=rigeng"),
        DiscoverPair("新作", "comic_sort=xinzuo"),
      ]),
    ];
  }
}
