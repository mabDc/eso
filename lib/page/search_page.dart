import 'dart:ui';

import 'package:eso/api/api_from_rule.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chapter_page.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = Provider.of<Profile>(context, listen: false);
    return ChangeNotifierProvider(
      create: (context) => SearchProvider(
        threadCount: profile.searchCount,
        searchOption: SearchOption.values[profile.searchOption],
      ),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: TextField(
            cursorColor: Theme.of(context).primaryColor,
            cursorRadius: Radius.circular(2),
            selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              hintText: "search keyword",
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
                fontSize: 12,
              ),
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 4),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
                ),
              ),
              prefixIconConstraints: BoxConstraints(),
            ),
            maxLines: 1,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              height: 1.25,
            ),
            onSubmitted: Provider.of<SearchProvider>(context, listen: false).search,
          ),
        ),
        body: Consumer<SearchProvider>(
          builder: (context, provider, child) {
            if (provider.searchListNone.length == 0 && provider.rulesCount == 0) {
              return Center(child: Text('正在初始化或者尚未可搜索源'));
            }
            final searchList = provider.searchOption == SearchOption.None
                ? provider.searchListNone
                : provider.searchOption == SearchOption.Normal
                    ? provider.searchListNormal
                    : provider.searchListAccurate;
            final count = searchList.length;
            return ListView.separated(
              padding: EdgeInsets.all(8),
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemCount: searchList.length + 2,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return FittedBox(
                    child: Container(
                      height: 30,
                      child: Row(
                        children: [
                          FlatButton(
                            onPressed: null,
                            child: Text("过滤条件"),
                          ),
                          FlatButton(
                            onPressed: () {
                              provider.searchOption = SearchOption.None;
                              profile.searchOption = SearchOption.None.index;
                            },
                            child: Text(
                              "无",
                              style: provider.searchOption == SearchOption.None
                                  ? TextStyle(color: theme.primaryColor)
                                  : TextStyle(),
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              provider.searchOption = SearchOption.Normal;
                              profile.searchOption = SearchOption.Normal.index;
                            },
                            child: Text(
                              "普通",
                              style: provider.searchOption == SearchOption.Normal
                                  ? TextStyle(color: theme.primaryColor)
                                  : TextStyle(),
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              provider.searchOption = SearchOption.Accurate;
                              profile.searchOption = SearchOption.Accurate.index;
                            },
                            child: Text(
                              "精确",
                              style: provider.searchOption == SearchOption.Accurate
                                  ? TextStyle(color: theme.primaryColor)
                                  : TextStyle(),
                            ),
                          ),
                          FlatButton(
                            onPressed: null,
                            child: Text("并发数"),
                          ),
                          Center(
                            child: DropdownButton<int>(
                              items: [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120]
                                  .map((count) => DropdownMenuItem<int>(
                                        child: Text('$count'),
                                        value: count,
                                      ))
                                  .toList(),
                              isDense: true,
                              underline: Container(),
                              value: context.select(
                                  (SearchProvider provider) => provider.threadCount),
                              onChanged: (value) {
                                Provider.of<SearchProvider>(context, listen: false)
                                    .threadCount = value;
                                profile.searchCount = value;
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
                if (index == 1) {
                  final progress = (provider.successCount + provider.failureCount) /
                      provider.rulesCount;
                  return Center(
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 90,
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey,
                              ),
                              Text((progress * 100).toStringAsFixed(0)),
                            ],
                          ),
                        ),
                        FittedBox(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: '请求数: ',
                                  style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyText1.color),
                                ),
                                TextSpan(
                                  text: '${provider.successCount}(成功)',
                                  style: TextStyle(color: Colors.green),
                                ),
                                TextSpan(
                                  text: ' | ',
                                  style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyText1.color),
                                ),
                                TextSpan(
                                  text: '${provider.failureCount}(失败)',
                                  style: TextStyle(color: Colors.red),
                                ),
                                TextSpan(
                                  text: ' | ',
                                  style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyText1.color),
                                ),
                                TextSpan(
                                  text: '${provider.rulesCount}(总数)',
                                  style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyText1.color),
                                ),
                                TextSpan(
                                  text: '\n',
                                  style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyText1.color),
                                ),
                                TextSpan(
                                  text: '结果个数: ',
                                  style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyText1.color),
                                ),
                                TextSpan(
                                  text: count.toString(),
                                  style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyText1.color),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return InkWell(
                  child: UiSearchItem(
                    item: searchList[index - 2],
                    showType: true,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ChapterPage(searchItem: searchList[index - 2]),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SearchProvider with ChangeNotifier {
  int _threadCount;
  int get threadCount => _threadCount;
  set threadCount(int value) {
    if (threadCount != value) {
      _threadCount = value;
      notifyListeners();
    }
  }

  SearchOption _searchOption;
  SearchOption get searchOption => _searchOption;
  set searchOption(SearchOption value) {
    if (_searchOption != value) {
      _searchOption = value;
      notifyListeners();
    }
  }

  int _rulesCount;
  int get rulesCount => _rulesCount;
  int _successCount;
  int get successCount => _successCount;
  int _failureCount;
  int get failureCount => _failureCount;
  List<Rule> _rules;

  final List<SearchItem> searchListNone = <SearchItem>[];
  final List<SearchItem> searchListNormal = <SearchItem>[];
  final List<SearchItem> searchListAccurate = <SearchItem>[];

  final _keys = Map<String, bool>();
  int _keySuffix;
  SearchProvider({int threadCount, SearchOption searchOption}) {
    _threadCount = threadCount ?? 10;
    _searchOption = searchOption ?? SearchOption.Normal;
    _rulesCount = 0;
    _successCount = 0;
    _failureCount = 0;
    _rules = <Rule>[];
    _keySuffix = 0;
    init();
  }

  void init() async {
    _rules = (await Global.ruleDao.findAllRules()).where((e) => e.enableSearch).toList();
    _rulesCount = _rules.length;
    notifyListeners();
  }

  void search(String keyword) async {
    _keys.forEach((key, value) => _keys[key] = false);
    await Future.delayed(Duration(milliseconds: 300));
    print("search $keyword");
    searchListNone.clear();
    searchListNormal.clear();
    searchListAccurate.clear();
    _keySuffix++;
    _successCount = 0;
    _failureCount = 0;
    notifyListeners();
    for (var i = 0; i < threadCount; i++) {
      final count = _rules.length - 1 - i;
      _keys.addAll({"$_keySuffix$i": true});
      final realCount = count < 0 ? 0 : count ~/ threadCount + 1;
      ((String key) async {
        for (var j = 0; j < realCount; j++) {
          if (_keys[key]) {
            try {
              (await APIFromRUle(_rules[j * threadCount + i], int.parse("$key$j"))
                      .search(keyword, 1, 20))
                  .forEach((item) {
                if (_keys[key]) {
                  searchListNone.add(item);
                  if (item.name.contains(keyword)) {
                    searchListNormal.add(item);
                    if (item.name == keyword) {
                      searchListAccurate.add(item);
                    }
                  }
                }
              });
              _successCount++;
              notifyListeners();
            } catch (e) {
              print(e);
              _failureCount++;
              notifyListeners();
            }
          }
        }
      })("$_keySuffix$i");
    }
  }

  @override
  void dispose() {
    _keys.forEach((key, value) => _keys[key] = false);
    searchListNone.clear();
    searchListNormal.clear();
    searchListAccurate.clear();
    super.dispose();
  }
}

// class SearchProvider with ChangeNotifier {
//   int _threadCount;
//   int get threadCount => _threadCount;
//   set threadCount(int value) {
//     if (threadCount != value) {
//       _threadCount = value;
//       notifyListeners();
//     }
//   }

//   SearchOption _searchOption;
//   SearchOption get searchOption => _searchOption;
//   set searchOption(SearchOption value) {
//     if (_searchOption != value) {
//       _searchOption = value;
//       notifyListeners();
//     }
//   }

//   int _rulesCount;
//   int get rulesCount => _rulesCount;
//   int _successCount;
//   int get successCount => _successCount;
//   int _failureCount;
//   int get failureCount => _failureCount;

//   final List<SearchItem> searchListNone = <SearchItem>[];
//   final List<SearchItem> searchListNormal = <SearchItem>[];
//   final List<SearchItem> searchListAccurate = <SearchItem>[];
//   final List<FlutterIsolate> _isolates = <FlutterIsolate>[];
//   List<Rule> _rules;

//   final _keys = Map<String, bool>();
//   var _keySuffix = 0;
//   SearchProvider({int threadCount = 5}) {
//     _threadCount = threadCount ?? 5;
//     _searchOption = SearchOption.Normal;
//     _rulesCount = 0;
//     _successCount = 0;
//     _failureCount = 0;
//     init();
//   }

//   void init() async {
//     _rules = (await Global.ruleDao.findAllRules()).where((e) => e.enableSearch).toList();
//     _rulesCount = _rules.length;
//     notifyListeners();
//   }

//   void search(String keyword) async {
//     _keys.forEach((key, value) => _keys[key] = false);
//     _isolates.forEach((isolate) {
//       isolate.pause();
//       isolate.kill();
//     });
//     print("search $keyword");
//     searchListNone.clear();
//     searchListNormal.clear();
//     searchListAccurate.clear();
//     _keySuffix++;
//     _successCount = 0;
//     _failureCount = 0;
//     notifyListeners();
//     for (var i = 0; i < threadCount; i++) {
//       final count = _rules.length - 1 - i;
//       _keys.addAll({"$_keySuffix$i": true});
//       final realCount = count < 0 ? 0 : count ~/ threadCount + 1;
//       // 立即执行 按线程
//       (() async {
//         for (var j = 0; j < realCount; j++) {
//           await APIFromRUle(_rules[j * threadCount + i]).searchBackground(
//             keyword,
//             1,
//             20,
//             engineId: int.parse('$_keySuffix$i'),
//             searchListNone: searchListNone,
//             searchListNormal: searchListNormal,
//             searchListAccurate: searchListAccurate,
//             successCallback: () {
//               _successCount++;
//               notifyListeners();
//             },
//             failureCallback: () {
//               _failureCount++;
//               notifyListeners();
//             },
//             key: '$_keySuffix$i',
//             keys: _keys,
//             isolates: _isolates,
//           );
//         }
//       })();
//     }
//   }

//   @override
//   void dispose() {
//     searchListNone.clear();
//     searchListNormal.clear();
//     searchListAccurate.clear();
//     _keys.forEach((key, value) => _keys[key] = false);
//     _isolates.forEach((isolate) {
//       isolate.pause();
//       isolate.kill();
//     });
//     _isolates.clear();
//     super.dispose();
//   }
// }

// //这里以计算斐波那契数列为例，返回的值是Future，因为是异步的
// void asyncFibonacci(int n) async {
//   //首先创建一个ReceivePort，为什么要创建这个？
//   //因为创建isolate所需的参数，必须要有SendPort，SendPort需要ReceivePort来创建
//   final response = new ReceivePort();
//   //开始创建isolate,Isolate.spawn函数是isolate.dart里的代码,_isolate是我们自己实现的函数
//   //_isolate是创建isolate必须要的参数。
//   await Isolate.spawn(_isolate, response.sendPort);
//   //获取sendPort来发送数据
//   final sendPort = await response.first as SendPort;
//   //接收消息的ReceivePort
//   final answer = new ReceivePort();
//   //发送数据
//   sendPort.send([n, answer.sendPort]);
//   answer.forEach((element) {
//     print(22);
//   });
//   //获得数据并返回
// }

// //创建isolate必须要的参数
// void _isolate(SendPort initialReplyTo) {
//   final port = new ReceivePort();
//   //绑定
//   initialReplyTo.send(port.sendPort);
//   //监听
//   port.listen((message) {
//     //获取数据并解析
//     final data = message[0] as int;
//     final send = message[1] as SendPort;
//     //返回结果
//     send.send(syncFibonacci(data));
//     send.send(syncFibonacci(data));
//     send.send(syncFibonacci(data));
//   });
// }

// int syncFibonacci(int n) {
//   return n < 2 ? n : syncFibonacci(n - 2) + syncFibonacci(n - 1);
// }
