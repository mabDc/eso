import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Manhualou implements API {
  @override
  String get origin => '漫画楼';

  @override
  String get originTag => 'Manhualou';

  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final dom = parse(utf8.decode(res.bodyBytes));
    return dom
        .querySelectorAll('#contList li')
        .map((item) => SearchItem(
              tags: <String>[],
              api: this,
              cover: '${item.querySelector('img').attributes["src"]}',
              name: '${item.querySelector('p').text}',
              author: '',
              chapter: '${item.querySelector('.tt').text}',
              description: '${item.querySelector('.updateon').text}',
              url: '${item.querySelector('a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    final query = params.values
        .where((pair) => pair.value != '')
        .map((pair) => pair.value)
        .join('-');
    if ('' != query) {
      return commonParse("https://www.manhualou.com/list/$query/$page/");
    }
    return commonParse("https://www.manhualou.com/list_$page/");
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        "https://www.manhualou.com/search/?keywords=$query&page=$page");
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('#chapter-list-1 a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}'.trim(),
              url: 'https://www.manhualou.com${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final json =
        RegExp("chapterImages\\s*=\\s*([^;]*)").firstMatch(res.body)[1];
    return (jsonDecode(json) as List)
        .map((s) => 'https://restp.dongqiniqin.com/$s')
        .toList();
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap("类型", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("儿童漫画", "ertong"),
        DiscoverPair("少年漫画", "shaonian"),
        DiscoverPair("少女漫画", "shaonv"),
        DiscoverPair("青年漫画", "qingnian"),
      ]),
      DiscoverMap("地区", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("日本", "riben"),
        DiscoverPair("大陆", "dalu"),
        DiscoverPair("香港", "hongkong"),
        DiscoverPair("台湾", "taiwan"),
        DiscoverPair("欧美", "oumei"),
        DiscoverPair("韩国", "hanguo"),
        DiscoverPair("其他", "qita"),
      ]),
      DiscoverMap("剧情", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("爱情", "aiqing"),
        DiscoverPair("少女爱情", "shaonvaiqing"),
        DiscoverPair("欢乐向", "huanlexiang"),
        DiscoverPair("耽美", "danmei"),
        DiscoverPair("东方", "dongfang"),
        DiscoverPair("其他", "qita"),
        DiscoverPair("冒险", "maoxian"),
        DiscoverPair("奇幻", "qihuan"),
        DiscoverPair("性转换", "xingzhuanhuan"),
        DiscoverPair("节操", "jiecao"),
        DiscoverPair("舰娘", "jianniang"),
        DiscoverPair("四格", "sige"),
        DiscoverPair("科幻", "kehuan"),
        DiscoverPair("校园", "xiaoyuan"),
        DiscoverPair("竞技", "jingji"),
        DiscoverPair("萌系", "mengxi"),
        DiscoverPair("机战", "jizhan"),
        DiscoverPair("后宫", "hougong"),
        DiscoverPair("格斗", "gedou"),
        DiscoverPair("百合", "baihe"),
        DiscoverPair("魔幻", "mohuan"),
        DiscoverPair("动作格斗", "dongzuogedou"),
        DiscoverPair("魔法", "mofa"),
        DiscoverPair("生活", "shenghuo"),
        DiscoverPair("轻小说", "qingxiaoshuo"),
        DiscoverPair("神鬼", "shengui"),
        DiscoverPair("悬疑", "xuanyi"),
        DiscoverPair("美食", "meishi"),
        DiscoverPair("伪娘", "weiniang"),
        DiscoverPair("治愈", "zhiyu"),
        DiscoverPair("颜艺", "yanyi"),
        DiscoverPair("恐怖", "kongbu"),
        DiscoverPair("职场", "zhichang"),
        DiscoverPair("热血", "rexue"),
        DiscoverPair("侦探", "zhentan"),
        DiscoverPair("搞笑", "gaoxiao"),
        DiscoverPair("音乐舞蹈", "yinyuewudao"),
        DiscoverPair("历史", "lishi"),
        DiscoverPair("战争", "zhanzheng"),
        DiscoverPair("励志", "lizhi"),
        DiscoverPair("高清单行", "gaoqingdanxing"),
        DiscoverPair("西方魔幻", "xifangmohuan"),
        DiscoverPair("宅系", "zhaixi"),
        DiscoverPair("魔幻神话", "mohuanshenhua"),
        DiscoverPair("校园青春", "xiaoyuanqingchun"),
        DiscoverPair("综合其它", "zongheqita"),
        DiscoverPair("轻松搞笑", "qingsonggaoxiao"),
        DiscoverPair("体育竞技", "tiyujingji"),
        DiscoverPair("同人漫画", "tongrenmanhua"),
        DiscoverPair("布卡漫画", "bukamanhua"),
        DiscoverPair("科幻未来", "kehuanweilai"),
        DiscoverPair("悬疑探案", "xuanyitanan"),
        DiscoverPair("短篇漫画", "duanpianmanhua"),
        DiscoverPair("萌", "meng"),
        DiscoverPair("侦探推理", "zhentantuili"),
        DiscoverPair("其它漫画", "qitamanhua"),
        DiscoverPair("武侠格斗", "wuxiagedou"),
        DiscoverPair("科幻魔幻", "kehuanmohuan"),
        DiscoverPair("耽美BL", "danmeiBL"),
        DiscoverPair("青春", "qingchun"),
        DiscoverPair("恋爱", "lianai"),
        DiscoverPair("神魔", "shenmo"),
        DiscoverPair("恐怖鬼怪", "kongbuguiguai"),
        DiscoverPair("青年漫画", "qingnianmanhua"),
        DiscoverPair("四格漫画", "sigemanhua"),
        DiscoverPair("搞笑喜剧", "gaoxiaoxiju"),
        DiscoverPair("玄幻", "xuanhuan"),
        DiscoverPair("动作", "dongzuo"),
        DiscoverPair("武侠", "wuxia"),
        DiscoverPair("穿越", "chuanyue"),
        DiscoverPair("同人", "tongren"),
        DiscoverPair("架空", "jiakong"),
        DiscoverPair("霸总", "bazong"),
        DiscoverPair("萝莉", "luoli"),
        DiscoverPair("总裁", "zongcai"),
        DiscoverPair("古风", "gufeng"),
        DiscoverPair("推理", "tuili"),
        DiscoverPair("恐怖灵异", "kongbulingyi"),
        DiscoverPair("修真", "xiuzhen"),
        DiscoverPair("灵异", "lingyi"),
        DiscoverPair("真人", "zhenren"),
        DiscoverPair("历史漫画", "lishimanhua"),
        DiscoverPair("漫改", "mangai"),
        DiscoverPair("剧情", "juqing"),
        DiscoverPair("美少女", "meishaonv"),
        DiscoverPair("故事", "gushi"),
        DiscoverPair("都市", "dushi"),
        DiscoverPair("社会", "shehui"),
        DiscoverPair("竞技体育", "jingjitiyu"),
        DiscoverPair("少女", "shaonv"),
        DiscoverPair("御姐", "yujie"),
        DiscoverPair("运动", "yundong"),
        DiscoverPair("杂志", "zazhi"),
        DiscoverPair("吸血", "xixie"),
        DiscoverPair("泡泡", "paopao"),
        DiscoverPair("彩虹", "caihong"),
        DiscoverPair("恋爱生活", "lianaishenghuo"),
        DiscoverPair("修真热血玄幻", "xiuzhenrexuexuanhuan"),
        DiscoverPair("恋爱玄幻", "lianaixuanhuan"),
        DiscoverPair("生活悬疑灵异", "shenghuoxuanyilingyi"),
        DiscoverPair("霸总生活", "bazongshenghuo"),
        DiscoverPair("恋爱生活玄幻", "lianaishenghuoxuanhuan"),
        DiscoverPair("架空后宫古风", "jiakonghougonggufeng"),
        DiscoverPair("生活悬疑古风", "shenghuoxuanyigufeng"),
        DiscoverPair("恋爱热血玄幻", "lianairexuexuanhuan"),
        DiscoverPair("恋爱校园生活", "lianaixiaoyuanshenghuo"),
        DiscoverPair("玄幻动作", "xuanhuandongzuo"),
        DiscoverPair("玄幻科幻", "xuanhuankehuan"),
        DiscoverPair("恋爱生活励志", "lianaishenghuolizhi"),
        DiscoverPair("悬疑恐怖", "xuanyikongbu"),
        DiscoverPair("游戏", "youxi"),
        DiscoverPair("恋爱生活科幻", "lianaishenghuokehuan"),
        DiscoverPair("修真灵异动作", "xiuzhenlingyidongzuo"),
        DiscoverPair("恋爱校园玄幻", "lianaixiaoyuanxuanhuan"),
        DiscoverPair("热血动作", "rexuedongzuo"),
        DiscoverPair("恋爱科幻", "lianaikehuan"),
        DiscoverPair("恋爱搞笑玄幻", "lianaigaoxiaoxuanhuan"),
        DiscoverPair("恋爱后宫古风", "lianaihougonggufeng"),
        DiscoverPair("恋爱搞笑穿越", "lianaigaoxiaochuanyue"),
        DiscoverPair("搞笑热血", "gaoxiaorexue"),
        DiscoverPair("修真恋爱架空", "xiuzhenlianaijiakong"),
        DiscoverPair("搞笑古风穿越", "gaoxiaogufengchuanyue"),
        DiscoverPair("霸总恋爱生活", "bazonglianaishenghuo"),
        DiscoverPair("恋爱古风穿越", "lianaigufengchuanyue"),
        DiscoverPair("玄幻古风", "xuanhuangufeng"),
        DiscoverPair("校园搞笑生活", "xiaoyuangaoxiaoshenghuo"),
        DiscoverPair("恋爱校园", "lianaixiaoyuan"),
        DiscoverPair("热血玄幻", "rexuexuanhuan"),
        DiscoverPair("恋爱生活悬疑", "lianaishenghuoxuanyi"),
        DiscoverPair("唯美", "weimei"),
        DiscoverPair("霸总恋爱", "bazonglianai"),
        DiscoverPair("悬疑动作", "xuanyidongzuo"),
        DiscoverPair("搞笑生活", "gaoxiaoshenghuo"),
        DiscoverPair("热血架空", "rexuejiakong"),
        DiscoverPair("恋爱校园搞笑", "lianaixiaoyuangaoxiao"),
        DiscoverPair("校园生活动作", "xiaoyuanshenghuodongzuo"),
        DiscoverPair("恋爱搞笑生活", "lianaigaoxiaoshenghuo"),
        DiscoverPair("修真热血动作", "xiuzhenrexuedongzuo"),
        DiscoverPair("热血玄幻动作", "rexuexuanhuandongzuo"),
        DiscoverPair("恋爱搞笑励志", "lianaigaoxiaolizhi"),
        DiscoverPair("搞笑生活玄幻", "gaoxiaoshenghuoxuanhuan"),
        DiscoverPair("恋爱搞笑科幻", "lianaigaoxiaokehuan"),
        DiscoverPair("悬疑古风", "xuanyigufeng"),
        DiscoverPair("恋爱架空古风", "lianaijiakonggufeng"),
        DiscoverPair("热血科幻战争", "rexuekehuanzhanzheng"),
        DiscoverPair("生活悬疑", "shenghuoxuanyi"),
        DiscoverPair("修真玄幻", "xiuzhenxuanhuan"),
        DiscoverPair("霸总恋爱玄幻", "bazonglianaixuanhuan"),
        DiscoverPair("搞笑生活励志", "gaoxiaoshenghuolizhi"),
        DiscoverPair("恋爱校园竞技", "lianaixiaoyuanjingji"),
        DiscoverPair("冒险热血玄幻", "maoxianrexuexuanhuan"),
        DiscoverPair("冒险热血", "maoxianrexue"),
        DiscoverPair("恋爱冒险古风", "lianaimaoxiangufeng"),
        DiscoverPair("恋爱搞笑古风", "lianaigaoxiaogufeng"),
        DiscoverPair("恋爱古风", "lianaigufeng"),
        DiscoverPair("霸总恋爱搞笑", "bazonglianaigaoxiao"),
        DiscoverPair("恋爱玄幻古风", "lianaixuanhuangufeng"),
        DiscoverPair("搞笑生活穿越", "gaoxiaoshenghuochuanyue"),
        DiscoverPair("恋爱搞笑后宫", "lianaigaoxiaohougong"),
        DiscoverPair("恋爱冒险玄幻", "lianaimaoxianxuanhuan"),
        DiscoverPair("恋爱搞笑悬疑", "lianaigaoxiaoxuanyi"),
        DiscoverPair("恋爱玄幻穿越", "lianaixuanhuanchuanyue"),
        DiscoverPair("生活玄幻", "shenghuoxuanhuan"),
        DiscoverPair("校园冒险搞笑", "xiaoyuanmaoxiangaoxiao"),
        DiscoverPair("恋爱生活古风", "lianaishenghuogufeng"),
        DiscoverPair("恋爱搞笑架空", "lianaigaoxiaojiakong"),
        DiscoverPair("冒险热血动作", "maoxianrexuedongzuo"),
        DiscoverPair("爆笑", "baoxiao"),
        DiscoverPair("热血玄幻悬疑", "rexuexuanhuanxuanyi"),
        DiscoverPair("恋爱冒险搞笑", "lianaimaoxiangaoxiao"),
        DiscoverPair("修真生活玄幻", "xiuzhenshenghuoxuanhuan"),
        DiscoverPair("恋爱悬疑", "lianaixuanyi"),
        DiscoverPair("恋爱校园励志", "lianaixiaoyuanlizhi"),
        DiscoverPair("修真恋爱古风", "xiuzhenlianaigufeng"),
        DiscoverPair("复仇", "fuchou"),
        DiscoverPair("虐心", "nuexin"),
        DiscoverPair("纯爱", "chunai"),
        DiscoverPair("蔷薇", "qiangwei"),
        DiscoverPair("震撼", "zhenhan"),
        DiscoverPair("惊悚", "jingsong"),
      ]),
      DiscoverMap("字母", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("A", "a"),
        DiscoverPair("B", "b"),
        DiscoverPair("C", "c"),
        DiscoverPair("D", "d"),
        DiscoverPair("E", "e"),
        DiscoverPair("F", "f"),
        DiscoverPair("G", "g"),
        DiscoverPair("H", "h"),
        DiscoverPair("I", "i"),
        DiscoverPair("J", "j"),
        DiscoverPair("K", "k"),
        DiscoverPair("L", "l"),
        DiscoverPair("M", "m"),
        DiscoverPair("N", "n"),
        DiscoverPair("O", "o"),
        DiscoverPair("P", "p"),
        DiscoverPair("Q", "q"),
        DiscoverPair("R", "r"),
        DiscoverPair("S", "s"),
        DiscoverPair("T", "t"),
        DiscoverPair("U", "u"),
        DiscoverPair("V", "v"),
        DiscoverPair("W", "w"),
        DiscoverPair("X", "x"),
        DiscoverPair("Y", "y"),
        DiscoverPair("Z", "z"),
        DiscoverPair("其他", "1"),
      ]),
      DiscoverMap("进度", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("已完结", "wanjie"),
        DiscoverPair("连载中", "lianzai"),
      ]),
    ];
  }
}
