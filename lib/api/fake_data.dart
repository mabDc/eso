import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liquidcore/liquidcore.dart';

import '../global.dart';

class FakeData {

  void test(BuildContext context) async {
    JSContext jsContext = JSContext();
    int start = DateTime.now().millisecondsSinceEpoch;
    String script =
    await DefaultAssetBundle.of(context).loadString(Global.cheerioFile);
    await jsContext.evaluateScript(script);
    final a = await jsContext.evaluateScript(
        "var \$ = cheerio.load('<div><a>111</a></div>');\$('div').find('*').text()");
    print(a);
    int end = DateTime.now().millisecondsSinceEpoch;
    print(end - start);
  }

  static List<SearchItem> get searchList => searchListJson.map((item) => SearchItem(
    cover: '${item["cover"]}!cover-400',
    title: '${item["title"]}',
    origin: "漫客栈💰",
    author: '${item["author_title"]}',
    chapter: '${item["chapter_title"]}',
    description: '${item["feature"]}',
    url: '${item["comic_id"]}',
  )).toList();

  static List<ChapterItem> get chapterList => chapterListJson.map((chapter){
    final time = DateTime.fromMillisecondsSinceEpoch(int.parse(chapter["start_time"]) * 1000);
    return ChapterItem(
        cover: chapter["cover"] == null ? null : '${chapter["cover"]}!cover-400',
        title: '${chapter["title"]}',
        time: '$time'.trim().substring(0, 16),
        url:'https://comic.mkzhan.com/chapter/content/?chapter_id=${chapter["chapter_id"]}&comic_id=${shelfItem["comic_id"]}'
    );
  }).toList();


  static const Map shelfItem = {
    "comic_id": "206800",
    "chapter_id": "713011",
    "start_chapter_id": "471790",
    "title": "都市喵奇谭",
    "cover":
        "http://oss.mkzcdn.com/comic/cover/20170712/596584cf25704-1309x1745.jpg",
    "author_title": "橘花散里&saremi",
    "chapter_num": "37",
    "chapter_title": "番外：发糖？！",
    "feature": "猫妖续命，交易灵魂",
    "finish": "2",
    "theme_id": "6,12",
    "durChapter": '第1回 贪婪（上）',
    "chapterNum": 36,
  };

  static const picUrl = "https://oss.mkzcdn.com/comic/page/20170612/593e5ce4a295e-1500x2250.jpg!page-1200";

  static const List searchListJson = [
    {
      "comic_id": "212807",
      "chapter_id": "852863",
      "start_chapter_id": "711548",
      "title": "极品战兵在都市",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20180608\/5b1a2402eafec-599x799.jpg",
      "author_title": "二次元动漫",
      "chapter_num": "149",
      "chapter_title": "第147话",
      "feature": "混迹黑道如鱼得水",
      "finish": "1",
      "theme_id": "3,7"
    },
    {
      "comic_id": "213111",
      "chapter_id": "852914",
      "start_chapter_id": "727905",
      "title": "护花高手在都市",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20181204\/5c066aab4d67d-750x999.jpg",
      "author_title": "极漫文化",
      "chapter_num": "127",
      "chapter_title": "第126话 真相大白",
      "feature": "神秘少年桃花接踵而至",
      "finish": "1",
      "theme_id": "2,3,8"
    },
    {
      "comic_id": "213792",
      "chapter_id": "852939",
      "start_chapter_id": "770991",
      "title": "风水天师在都市",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20190710\/5d2544bd74101-750x999.jpg",
      "author_title": "极漫文化",
      "chapter_num": "102",
      "chapter_title": "第99话 第二波狗粮",
      "feature": "风水少年都市收后宫！",
      "finish": "1",
      "theme_id": "3,8,12"
    },
    {
      "comic_id": "214535",
      "chapter_id": "852777",
      "start_chapter_id": "815102",
      "title": "系统仙尊在都市",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20190926\/5d8c226844080-742x990.jpg",
      "author_title": "极漫文化",
      "chapter_num": "43",
      "chapter_title": "第41话 又杠上了",
      "feature": "开启自己的开挂人生！",
      "finish": "1",
      "theme_id": "2,3,8,10"
    },
    {
      "comic_id": "214243",
      "chapter_id": "851723",
      "start_chapter_id": "799378",
      "title": "重生之都市狂仙",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20190926\/5d8c34d341bb9-750x999.jpg",
      "author_title": "阿里文学",
      "chapter_num": "45",
      "chapter_title": "第45话 灭了又如何",
      "feature": "仙帝重生于繁华都市",
      "finish": "1",
      "theme_id": "3,5,12"
    },
    {
      "comic_id": "214345",
      "chapter_id": "851698",
      "start_chapter_id": "806510",
      "title": "都市至尊",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20190426\/5cc2be08821d4-749x999.jpg",
      "author_title": "金橙动漫",
      "chapter_num": "47",
      "chapter_title": "第47话 人外有人",
      "feature": "至尊道医纵横都市",
      "finish": "1",
      "theme_id": "7,10,12"
    },
    {
      "comic_id": "213476",
      "chapter_id": "744059",
      "start_chapter_id": "743921",
      "title": "妙手天医在都市",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20181010\/5bbdaf6a9b216-600x800.jpg",
      "author_title": "天翼爱动漫",
      "chapter_num": "123",
      "chapter_title": "第123话 最终话",
      "feature": "行走于权势和死神之间",
      "finish": "2",
      "theme_id": "7,12"
    },
    {
      "comic_id": "214683",
      "chapter_id": "852779",
      "start_chapter_id": "830929",
      "title": "终极兵王混都市",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20190710\/5d259c3adf847-750x999.jpg",
      "author_title": "六月雪工作室",
      "chapter_num": "34",
      "chapter_title": "第34话",
      "feature": "百分百胜率单兵的新生",
      "finish": "1",
      "theme_id": "3,8"
    },
    {
      "comic_id": "214172",
      "chapter_id": "810727",
      "start_chapter_id": "794373",
      "title": "超级保安在都市",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20190308\/5c81c68010631-750x999.jpg",
      "author_title": "开源动漫",
      "chapter_num": "54",
      "chapter_title": "第54话 我替他保护你",
      "feature": "万丈红尘，怎破得开？",
      "finish": "2",
      "theme_id": "7,10"
    },
    {
      "comic_id": "214366",
      "chapter_id": "851947",
      "start_chapter_id": "807563",
      "title": "护花兵王在都市",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20190826\/5d6377606ed6b-750x999.jpg",
      "author_title": "杭漫文化",
      "chapter_num": "34",
      "chapter_title": "第34话 我是她未婚夫",
      "feature": "打脸权贵恶霸…大概吧",
      "finish": "1",
      "theme_id": "12,16"
    },
    {
      "comic_id": "214426",
      "chapter_id": "851752",
      "start_chapter_id": "812410",
      "title": "都市之修真归来",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20190520\/5ce25eba9609f-750x999.jpg",
      "author_title": "金橙动漫",
      "chapter_num": "45",
      "chapter_title": "第45话 不是我对手",
      "feature": "在各方势力中强势逆袭",
      "finish": "1",
      "theme_id": "5,10,12"
    },
    {
      "comic_id": "214862",
      "chapter_id": "852444",
      "start_chapter_id": "845974",
      "title": "都市仙王",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20190917\/5d80ad9058dcd-750x999.jpg",
      "author_title": "博易动漫",
      "chapter_num": "28",
      "chapter_title": "第28话",
      "feature": "天上地下，有我无敌！",
      "finish": "1",
      "theme_id": "5,8,12"
    },
    {
      "comic_id": "214348",
      "chapter_id": "827452",
      "start_chapter_id": "806571",
      "title": "都市最强无良",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20190619\/5d09f1016ef29-750x999.jpg",
      "author_title": "金橙动漫",
      "chapter_num": "18",
      "chapter_title": "第17话 保护费",
      "feature": "无良修仙，历劫扬帆",
      "finish": "2",
      "theme_id": "4,10,12"
    },
    {
      "comic_id": "206800",
      "chapter_id": "713011",
      "start_chapter_id": "471790",
      "title": "都市喵奇谭",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20170712\/596584cf25704-1309x1745.jpg",
      "author_title": "橘花散里&saremi",
      "chapter_num": "37",
      "chapter_title": "番外：发糖？！",
      "feature": "猫妖续命，交易灵魂",
      "finish": "2",
      "theme_id": "6,12"
    },
    {
      "comic_id": "214863",
      "chapter_id": "852257",
      "start_chapter_id": "846075",
      "title": "都市巅峰高手",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20190918\/5d8192bc8ccbc-750x999.jpg",
      "author_title": "博易动漫",
      "chapter_num": "10",
      "chapter_title": "第9话 国画创作",
      "feature": "绝世强者抚养的孤儿",
      "finish": "1",
      "theme_id": "8,9,23"
    },
    {
      "comic_id": "213726",
      "chapter_id": "806645",
      "start_chapter_id": "763495",
      "title": "都市猎魔人",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20181129\/5bffc57004953-600x800.jpg",
      "author_title": "星际互娱",
      "chapter_num": "23",
      "chapter_title": "第23话 决心",
      "feature": "独特体质引出惊天秘密",
      "finish": "2",
      "theme_id": "8,12"
    },
    {
      "comic_id": "212758",
      "chapter_id": "719018",
      "start_chapter_id": "707858",
      "title": "穿越都市",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/cover\/20180603\/5b13f9385df75-630x840.jpg",
      "author_title": "肉松rous",
      "chapter_num": "7",
      "chapter_title": "羡慕",
      "feature": "可能是最废穿越漫",
      "finish": "1",
      "theme_id": "6,9,20"
    }
  ];

  static const List chapterListJson = [
    {
      "chapter_id": "471790",
      "number": "1",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190910\/5d7e5d3f81346-800x450.jpg",
      "part": "1",
      "title": "第1回 贪婪（上）",
      "title_alias": "1",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "471795",
      "number": "2",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190514\/5cda728dc0679-800x450.jpg",
      "part": "1",
      "title": "第2回 贪婪（下）",
      "title_alias": "2",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "471806",
      "number": "3",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190911\/5d7fb8bfd0eb1-800x450.jpg",
      "part": "1",
      "title": "第3回 抉择（上）",
      "title_alias": "3",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "471817",
      "number": "4",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190514\/5cda73562eae0-800x450.jpg",
      "part": "1",
      "title": "第4回 抉择（下）",
      "title_alias": "4",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "471823",
      "number": "5",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190911\/5d7f16d4c4539-800x450.jpg",
      "part": "1",
      "title": "第5回 偷拍风波（上）",
      "title_alias": "5",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "475231",
      "number": "6",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190514\/5cdad80e32623-800x450.jpg",
      "part": "1",
      "title": "第6回 偷拍风波（下）",
      "title_alias": "6",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "475233",
      "number": "7",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190514\/5cdad81ab6e28-800x450.jpg",
      "part": "1",
      "title": "第7回 跨越种族的爱（上）",
      "title_alias": "7",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "475235",
      "number": "8",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190916\/5d810c65606ea-800x450.jpg",
      "part": "1",
      "title": "第8回 跨越种族的爱（下）",
      "title_alias": "8",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "475237",
      "number": "9",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190911\/5d7bbf8c4e0f4-800x450.jpg",
      "part": "1",
      "title": "第9回 弃坑者注意！（上）",
      "title_alias": "9",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "475240",
      "number": "10",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190514\/5cdad85ece232-800x450.jpg",
      "part": "1",
      "title": "第10回 弃坑者注意！（下）",
      "title_alias": "10",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "477368",
      "number": "11",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190913\/5d80a343ebc85-800x450.jpg",
      "part": "1",
      "title": "第11回 穿越者（一）",
      "title_alias": "11",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "477370",
      "number": "12",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190912\/5d7f5c1f130e5-800x450.jpg",
      "part": "1",
      "title": "第12回 穿越者（二）",
      "title_alias": "12",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "477371",
      "number": "13",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190910\/5d77762a486dd-800x450.jpg",
      "part": "1",
      "title": "第13回 穿越者（三）",
      "title_alias": "13",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "477372",
      "number": "14",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190910\/5d78598cc4684-800x450.jpg",
      "part": "1",
      "title": "第14回 穿越者（四）",
      "title_alias": "14",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1495358520"
    },
    {
      "chapter_id": "496216",
      "number": "15",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190913\/5d7c57156aed7-800x450.jpg",
      "part": "1",
      "title": "第15回 生日快乐（上）",
      "title_alias": "15",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497315480"
    },
    {
      "chapter_id": "496217",
      "number": "16",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190514\/5cdda5c64b09c-800x450.jpg",
      "part": "1",
      "title": "第16回 生日快乐（中）",
      "title_alias": "16",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497315540"
    },
    {
      "chapter_id": "496218",
      "number": "17",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190915\/5d80c0e6e96eb-800x450.jpg",
      "part": "1",
      "title": "第17回 生日快乐（下）",
      "title_alias": "17",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497315660"
    },
    {
      "chapter_id": "496219",
      "number": "18",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190514\/5cdda5dec3f54-800x450.jpg",
      "part": "1",
      "title": "第18回 离家风波（上）",
      "title_alias": "18",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497315720"
    },
    {
      "chapter_id": "496220",
      "number": "19",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190912\/5d7a8918cd924-800x450.jpg",
      "part": "1",
      "title": "第19回 离家风波（中）",
      "title_alias": "19",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497315840"
    },
    {
      "chapter_id": "496221",
      "number": "20",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190911\/5d7da8b4b0865-800x450.jpg",
      "part": "1",
      "title": "第20回 离家风波（下）",
      "title_alias": "20",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497315900"
    },
    {
      "chapter_id": "496222",
      "number": "21",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190514\/5cdda6007f69b-800x450.jpg",
      "part": "1",
      "title": "第21回 黑狱风云（一）",
      "title_alias": "21",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497315960"
    },
    {
      "chapter_id": "496223",
      "number": "22",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190911\/5d7bdfbf2aaa7-800x450.jpg",
      "part": "1",
      "title": "第22回 黑狱风云（二）",
      "title_alias": "22",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497316020"
    },
    {
      "chapter_id": "496224",
      "number": "23",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190911\/5d7dce351321e-800x450.jpg",
      "part": "1",
      "title": "第23回 黑狱风云（三）",
      "title_alias": "23",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497316080"
    },
    {
      "chapter_id": "496225",
      "number": "24",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190913\/5d7c970ec16fa-800x450.jpg",
      "part": "1",
      "title": "第24回 凋零的曼陀罗（一）",
      "title_alias": "24",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497316140"
    },
    {
      "chapter_id": "496226",
      "number": "25",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190911\/5d7ff6285eda5-800x450.jpg",
      "part": "1",
      "title": "第25回 凋零的曼陀罗（二）",
      "title_alias": "25",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497316200"
    },
    {
      "chapter_id": "496227",
      "number": "26",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190911\/5d7930f172b95-800x450.jpg",
      "part": "1",
      "title": "第26回 凋零的曼陀罗（三）",
      "title_alias": "26",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497316260"
    },
    {
      "chapter_id": "496228",
      "number": "27",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190913\/5d7cbf362a99c-800x450.jpg",
      "part": "1",
      "title": "第27回 别扭猫和忠犬狗（一）",
      "title_alias": "27",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497316320"
    },
    {
      "chapter_id": "496229",
      "number": "28",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190912\/5d7bb3d1266d2-800x450.jpg",
      "part": "1",
      "title": "第28回 别扭猫和忠犬狗（二）",
      "title_alias": "28",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497316380"
    },
    {
      "chapter_id": "496230",
      "number": "29",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190912\/5d7cf225e12f9-800x450.jpg",
      "part": "1",
      "title": "第29回 逆转时光的幸福（一）",
      "title_alias": "29",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497316440"
    },
    {
      "chapter_id": "496231",
      "number": "30",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190914\/5d80c3dc82b3c-800x450.jpg",
      "part": "1",
      "title": "第30回 逆转时光的幸福（二）",
      "title_alias": "30",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497316500"
    },
    {
      "chapter_id": "496232",
      "number": "31",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190910\/5d7be275a0827-800x450.jpg",
      "part": "1",
      "title": "第31回 逆转时光的幸福（三）",
      "title_alias": "31",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497316620"
    },
    {
      "chapter_id": "496233",
      "number": "32",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190514\/5cdda68e31519-800x450.jpg",
      "part": "1",
      "title": "第32回 逆转时光的幸福（四）",
      "title_alias": "32",
      "is_vip": "0",
      "price": "0",
      "change_time": "1533547790",
      "is_theater": "0",
      "start_time": "1497316800"
    },
    {
      "chapter_id": "496234",
      "number": "33",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190514\/5cdda69e3cd87-800x450.jpg",
      "part": "1",
      "title": "第33回 逆转时光的幸福（五）",
      "title_alias": "33",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497316860"
    },
    {
      "chapter_id": "496235",
      "number": "34",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190911\/5d7c5ba817b22-800x450.jpg",
      "part": "1",
      "title": "第34回 逆转时光的幸福（六）",
      "title_alias": "34",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497317040"
    },
    {
      "chapter_id": "496237",
      "number": "35",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190912\/5d80dc0d642c4-800x450.jpg",
      "part": "1",
      "title": "第35回 逆转时光的幸福（七）",
      "title_alias": "35",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497317640"
    },
    {
      "chapter_id": "496238",
      "number": "36",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190910\/5d79318d26df8-800x450.jpg",
      "part": "1",
      "title": "第36回 大结局",
      "title_alias": "36",
      "is_vip": "0",
      "price": "0",
      "change_time": "0",
      "is_theater": "0",
      "start_time": "1497317700"
    },
    {
      "chapter_id": "713011",
      "number": "37",
      "sort": "9999",
      "cover":
          "http:\/\/oss.mkzcdn.com\/comic\/page\/20190910\/5d774d78b8447-800x450.jpg",
      "part": "1",
      "title": "番外：发糖？！",
      "title_alias": "37",
      "is_vip": "0",
      "price": "0",
      "change_time": "1538217607",
      "is_theater": "0",
      "start_time": "1529215440"
    }
  ];
}
