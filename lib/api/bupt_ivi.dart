import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';

class BuptIvi implements API {
  @override
  String get origin => '北邮ivi直播';

  @override
  String get originTag => 'BuptIvi';

  @override
  int get ruleContentType => API.VIDEO;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    if (page > 1) return <SearchItem>[];
    return list
        .map((item) => SearchItem(
              api: this,
              cover: 'https://www.bupt.edu.cn/images/logo.png',
              name: item[0],
              author: '',
              chapter: '',
              description: '北邮ivi电视直播',
              url: item[0] + ',' + item[1],
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return <SearchItem>[];
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    return <ChapterItem>[
      ChapterItem(
        cover: null,
        name: url.split(',')[0],
        time: null,
        url: url.split(',')[1],
      )
    ];
  }

  @override
  Future<List<String>> content(String url) async {
    return <String>[url];
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[];
  }

  final list = [
    ["CCTV-1综合", "http://ivi.bupt.edu.cn/hls/cctv1.m3u8"],
    ["CCTV-1高清", "http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8"],
    ["CCTV-2财经", "http://ivi.bupt.edu.cn/hls/cctv2.m3u8"],
    ["CCTV-3综艺", "http://ivi.bupt.edu.cn/hls/cctv3.m3u8"],
    ["CCTV-3高清", "http://ivi.bupt.edu.cn/hls/cctv3hd.m3u8"],
    ["CCTV-4中文国际", "http://ivi.bupt.edu.cn/hls/cctv4.m3u8"],
    ["CCTV-5+高清", "http://ivi.bupt.edu.cn/hls/cctv5phd.m3u8"],
    ["CCTV-6电影", "http://ivi.bupt.edu.cn/hls/cctv6.m3u8"],
    ["CCTV-6高清", "http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8"],
    ["CCTV-7军事农业", "http://ivi.bupt.edu.cn/hls/cctv7.m3u8"],
    ["CCTV-8电视剧", "http://ivi.bupt.edu.cn/hls/cctv8.m3u8"],
    ["CCTV-8高清", "http://ivi.bupt.edu.cn/hls/cctv8hd.m3u8"],
    ["CCTV-9纪录", "http://ivi.bupt.edu.cn/hls/cctv9.m3u8"],
    ["CCTV-10科教", "http://ivi.bupt.edu.cn/hls/cctv10.m3u8"],
    ["CCTV-11戏曲", "http://ivi.bupt.edu.cn/hls/cctv11.m3u8"],
    ["CCTV-12社会与法", "http://ivi.bupt.edu.cn/hls/cctv12.m3u8"],
    ["CCTV-13新闻", "http://ivi.bupt.edu.cn/hls/cctv13.m3u8"],
    ["CCTV-14少儿", "http://ivi.bupt.edu.cn/hls/cctv14.m3u8"],
    ["CCTV-15音乐", "http://ivi.bupt.edu.cn/hls/cctv15.m3u8"],
    ["CCTV-NEWS", "http://ivi.bupt.edu.cn/hls/cctv16.m3u8"],
    ["CHC高清电影", "http://ivi.bupt.edu.cn/hls/chchd.m3u8"],
    ["安徽卫视", "http://ivi.bupt.edu.cn/hls/ahtv.m3u8"],
    ["安徽卫视高清", "http://ivi.bupt.edu.cn/hls/ahhd.m3u8"],
    ["北京财经", "http://ivi.bupt.edu.cn/hls/btv5.m3u8"],
    ["北京纪实高清", "http://ivi.bupt.edu.cn/hls/btv11hd.m3u8"],
    ["北京卡酷少儿", "http://ivi.bupt.edu.cn/hls/btv10.m3u8"],
    ["北京科教", "http://ivi.bupt.edu.cn/hls/btv3.m3u8"],
    ["北京青年", "http://ivi.bupt.edu.cn/hls/btv8.m3u8"],
    ["北京生活", "http://ivi.bupt.edu.cn/hls/btv7.m3u8"],
    ["北京卫视", "http://ivi.bupt.edu.cn/hls/btv1.m3u8"],
    ["北京卫视高清", "http://ivi.bupt.edu.cn/hls/btv1hd.m3u8"],
    ["北京文艺", "http://ivi.bupt.edu.cn/hls/btv2.m3u8"],
    ["北京文艺高清", "http://ivi.bupt.edu.cn/hls/btv2hd.m3u8"],
    ["北京新闻", "http://ivi.bupt.edu.cn/hls/btv9.m3u8"],
    ["北京影视", "http://ivi.bupt.edu.cn/hls/btv4.m3u8"],
    ["兵团卫视", "http://ivi.bupt.edu.cn/hls/bttv.m3u8"],
    ["重庆卫视", "http://ivi.bupt.edu.cn/hls/cqtv.m3u8"],
    ["重庆卫视高清", "http://ivi.bupt.edu.cn/hls/cqhd.m3u8"],
    ["东方卫视", "http://ivi.bupt.edu.cn/hls/dftv.m3u8"],
    ["东方卫视高清", "http://ivi.bupt.edu.cn/hls/dfhd.m3u8"],
    ["福建东南卫视", "http://ivi.bupt.edu.cn/hls/dntv.m3u8"],
    ["甘肃卫视", "http://ivi.bupt.edu.cn/hls/gstv.m3u8"],
    ["广东卫视", "http://ivi.bupt.edu.cn/hls/gdtv.m3u8"],
    ["广东卫视高清", "http://ivi.bupt.edu.cn/hls/gdhd.m3u8"],
    ["广西卫视", "http://ivi.bupt.edu.cn/hls/gxtv.m3u8"],
    ["贵州卫视", "http://ivi.bupt.edu.cn/hls/gztv.m3u8"],
    ["河北卫视", "http://ivi.bupt.edu.cn/hls/hebtv.m3u8"],
    ["河南卫视", "http://ivi.bupt.edu.cn/hls/hntv.m3u8"],
    ["黑龙江卫视", "http://ivi.bupt.edu.cn/hls/hljtv.m3u8"],
    ["黑龙江卫视高清", "http://ivi.bupt.edu.cn/hls/hljhd.m3u8"],
    ["湖北卫视", "http://ivi.bupt.edu.cn/hls/hbtv.m3u8"],
    ["湖北卫视高清", "http://ivi.bupt.edu.cn/hls/hbhd.m3u8"],
    ["湖南卫视", "http://ivi.bupt.edu.cn/hls/hunantv.m3u8"],
    ["湖南卫视高清", "http://ivi.bupt.edu.cn/hls/hunanhd.m3u8"],
    ["吉林卫视", "http://ivi.bupt.edu.cn/hls/jltv.m3u8"],
    ["江苏卫视", "http://ivi.bupt.edu.cn/hls/jstv.m3u8"],
    ["江苏卫视高清", "http://ivi.bupt.edu.cn/hls/jshd.m3u8"],
    ["江西卫视", "http://ivi.bupt.edu.cn/hls/jxtv.m3u8"],
    ["辽宁卫视", "http://ivi.bupt.edu.cn/hls/lntv.m3u8"],
    ["辽宁卫视高清", "http://ivi.bupt.edu.cn/hls/lnhd.m3u8"],
    ["旅游卫视", "http://ivi.bupt.edu.cn/hls/lytv.m3u8"],
    ["内蒙古卫视", "http://ivi.bupt.edu.cn/hls/nmtv.m3u8"],
    ["宁夏卫视", "http://ivi.bupt.edu.cn/hls/nxtv.m3u8"],
    ["青海卫视", "http://ivi.bupt.edu.cn/hls/qhtv.m3u8"],
    ["厦门卫视", "http://ivi.bupt.edu.cn/hls/xmtv.m3u8"],
    ["山东卫视", "http://ivi.bupt.edu.cn/hls/sdtv.m3u8"],
    ["山东卫视高清", "http://ivi.bupt.edu.cn/hls/sdhd.m3u8"],
    ["山西卫视", "http://ivi.bupt.edu.cn/hls/sxrtv.m3u8"],
    ["陕西卫视", "http://ivi.bupt.edu.cn/hls/sxtv.m3u8"],
    ["深圳卫视", "http://ivi.bupt.edu.cn/hls/sztv.m3u8"],
    ["深圳卫视高清", "http://ivi.bupt.edu.cn/hls/szhd.m3u8"],
    ["四川卫视", "http://ivi.bupt.edu.cn/hls/sctv.m3u8"],
    ["天津卫视", "http://ivi.bupt.edu.cn/hls/tjtv.m3u8"],
    ["天津卫视高清", "http://ivi.bupt.edu.cn/hls/tjhd.m3u8"],
    ["西藏卫视", "http://ivi.bupt.edu.cn/hls/xztv.m3u8"],
    ["新疆卫视", "http://ivi.bupt.edu.cn/hls/xjtv.m3u8"],
    ["云南卫视", "http://ivi.bupt.edu.cn/hls/yntv.m3u8"],
    ["浙江卫视", "http://ivi.bupt.edu.cn/hls/zjtv.m3u8"],
    ["浙江卫视高清", "http://ivi.bupt.edu.cn/hls/zjhd.m3u8"],
  ];
}
