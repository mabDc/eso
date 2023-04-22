import 'dart:convert';
import 'package:eso/api/api_js_engine.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/main.dart';
import 'package:eso/page/chapter_page.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';

import '../api/api.dart';
import '../api/api_manager.dart';
import '../database/rule.dart';

class DiscoverWaterfallPage extends StatefulWidget {
  final Rule rule;
  DiscoverWaterfallPage({Key key, this.rule}) : super(key: key);

  @override
  State<DiscoverWaterfallPage> createState() => _DiscoverWaterfallPageState();
}

// 自动生成代码
// https://json.im/json2model/json2Dart.html
// {
//     "js": "'/category' + selectList.map(select => select.value).join('')",
//     "rules": [
//         {
//             "name": "标签",
//             "option": "",
//             "value": "",
//             "options": [
//                 {
//                     "option": "热血",
//                     "value": "/tags/6"
//                 }
//             ]
//         }
//     ]
// }

// 瀑布流结构有差异 增加key字段
// 自动生成代码
// https://json.im/json2model/json2Dart.html
// {
//     "rules": [
//         {
//             "name": "标签",
//             "key": "不需要显示",
//             "option": "",
//             "value": "",
//             "options": [
//                 {
//                     "option": "热血",
//                     "value": "/tags/6"
//                 }
//             ]
//         }
//     ]
// }

T cast<T>(x, T v) => x is T ? x : v;

class DiscoverRule {
  String js;
  List<Rules> rules;

  DiscoverRule({this.js, this.rules});

  DiscoverRule.fromJson(Map<String, dynamic> json, [String js]) {
    this.js = js == null ? json['js'] : js;
    if (json['rules'] != null) {
      rules = new List<Rules>();
      json['rules'].forEach((v) {
        rules.add(new Rules.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['js'] = this.js;
    if (this.rules != null) {
      data['rules'] = this.rules.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Rules {
  String name;
  String option;
  String value;
  String key;
  List<Options> options;

  Rules({this.name, this.option, this.value, this.options, this.key});

  Rules.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    option = json['option'];
    value = json['value'];
    key = json['key'];
    if (json['options'] != null) {
      options = new List<Options>();
      json['options'].forEach((v) {
        options.add(new Options.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['option'] = this.option;
    data['value'] = this.value;
    data['key'] = this.key;
    if (this.options != null) {
      data['options'] = this.options.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Options {
  String option;
  String value;

  Options({this.option, this.value});

  Options.fromJson(Map<String, dynamic> json) {
    option = json['option'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['option'] = this.option;
    data['value'] = this.value;
    return data;
  }
}

class _DiscoverWaterfallPageState extends State<DiscoverWaterfallPage> {
  DiscoverRule _discoverRule;
  String discoverUrl;

  @override
  void initState() {
    final s = widget.rule.discoverUrl.startsWith("测试新发现瀑布流")
        ? widget.rule.discoverUrl.substring("测试新发现瀑布流".length).trim()
        : widget.rule.discoverUrl.trim();
    final jsons = s.split("@@DiscoverRule:");
    if (jsons.length > 1) {
      _discoverRule = DiscoverRule.fromJson(
          jsonDecode(jsons[1].trim()),
          jsons[0].trim().startsWith("@js:")
              ? jsons[0].replaceFirst('@js:', '')
              : jsons[0]);
    } else {
      _discoverRule = DiscoverRule.fromJson(jsonDecode(s));
    }

    parseRule();
    super.initState();
  }

  parseRule() async {
    JSEngine.setEnvironment(1, widget.rule, "", widget.rule.host, "", "");
    discoverUrl = await JSEngine.evaluate(
        "${JSEngine.environment};;1+1;rules = ${jsonEncode(_discoverRule.rules)};;1+1;" +
            _discoverRule.js);
    setState(() {});
  }

  @override
  void dispose() {
    _discoverRule.rules.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: globalDecoration,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.rule.name),
          actions: [
            IconButton(
                onPressed: () {
                  Utils.toast("使用规则搜索 还没做呢 xx yy ");
                },
                icon: Icon(Icons.search))
          ],
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            _buildBanner(),
            _buildStickyBar(),
            _buildList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    if (_discoverRule == null) return SliverToBoxAdapter(child: Text("加载分类中。。。"));
    final nomal = TextStyle(color: Theme.of(context).textTheme.bodyText1.color);
    final primary = TextStyle(color: Theme.of(context).primaryColor);

    return SliverFixedExtentList(
      itemExtent: 35,
      delegate: SliverChildListDelegate([
        for (var rule in _discoverRule.rules)
          SizedBox(
            height: 35,
            child: Row(
              children: [
                Text(" " + rule.name),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: rule.options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final option = rule.options[index];
                      return TextButton(
                        onPressed: () {
                          rule.option = option.option;
                          rule.value = option.value;
                          parseRule();
                        },
                        child: Text(
                          option.option,
                          style: rule.value == option.value ? primary : nomal,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
      ]),
    );
  }

  Widget _buildStickyBar() {
    if (_discoverRule == null) return SliverToBoxAdapter(child: Text("加载结果中。。。"));

    return SliverPersistentHeader(
      pinned: true, //是否固定在顶部
      floating: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 35, //收起的高度
        maxHeight: 40, //展开的最大高度
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (var rule
                in _discoverRule.rules.where((element) => element.option.isNotEmpty))
              Card(
                child: Center(
                  child: Text(
                    " ${rule.name} : ${rule.option} ",
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_discoverRule == null || discoverUrl == null)
      return SliverToBoxAdapter(child: Text("加载地址中。。。"));
    return FutureBuilder<List<SearchItem>>(
      future: APIManager.discover(widget.rule.id, {"": DiscoverPair("", discoverUrl)}, 1),
      builder: (BuildContext context, AsyncSnapshot<List<SearchItem>> snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(child: Text("error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return SliverToBoxAdapter(child: Text("加载中。。。"));
        }
        return SliverList(
          delegate: SliverChildListDelegate(
            [
              for (var item in snapshot.data)
                InkWell(
                    onTap: () => Utils.startPageWait(
                        context,
                        ChapterPage(
                          searchItem: item,
                        )),
                    child: UiSearchItem(item: item)),
            ],
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
