import 'dart:ui';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_from_rule.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:eso/ui/edit/dropdown_search_edit.dart';
import 'package:eso/ui/widgets/empty_list_msg_view.dart';
import 'package:eso/ui/widgets/keyboard_dismiss_behavior_view.dart';
import 'package:eso/utils.dart';
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
    final profile = Provider.of<Profile>(context, listen: false);
    return ChangeNotifierProvider(
        create: (context) => SearchProvider(
              threadCount: profile.searchCount,
              searchOption: SearchOption.values[profile.searchOption],
              profile: profile,
            ),
        builder: (context, child) {
          return Scaffold(
            appBar: AppBarEx(
              titleSpacing: 0,
              title: SearchEdit(
                hintText: "请输入关键词",
                prefix: Container(
                  width: 48,
                  height: 20,
                  margin: const EdgeInsets.only(left: 16, right: 12),
                  child: DropdownButton<int>(
                    iconSize: 14,
                    style: TextStyle(
                        fontSize: 13,
                        color:
                            Theme.of(context).textTheme.bodyText1.color.withOpacity(0.5)),
                    isExpanded: true,
                    isDense: true,
                    underline: SizedBox(),
                    onChanged: (v) => Provider.of<SearchProvider>(context, listen: false)
                        .sourceType = v,
                    items: <DropdownMenuItem<int>>[
                      DropdownMenuItem<int>(child: Text('全部'), value: -1),
                      DropdownMenuItem<int>(
                          child: Text(API.getRuleContentTypeName(API.NOVEL)),
                          value: API.NOVEL),
                      DropdownMenuItem<int>(
                          child: Text(API.getRuleContentTypeName(API.MANGA)),
                          value: API.MANGA),
                      DropdownMenuItem<int>(
                          child: Text(API.getRuleContentTypeName(API.AUDIO)),
                          value: API.AUDIO),
                      DropdownMenuItem<int>(
                          child: Text(API.getRuleContentTypeName(API.VIDEO)),
                          value: API.VIDEO),
                    ],
                    value: Provider.of<SearchProvider>(context, listen: true).sourceType,
                  ),
                ),
                onSubmitted: Provider.of<SearchProvider>(context, listen: false).search,
              ),
              actions: [
                Container(width: 20),
              ],
            ),
            body: Consumer<SearchProvider>(
              builder: (context, provider, child) {
                final searchList = provider.searchOption == SearchOption.None
                    ? provider.searchListNone
                    : provider.searchOption == SearchOption.Normal
                        ? provider.searchListNormal
                        : provider.searchListAccurate;
                final count = searchList.length;
                final progress = provider.rulesCount == 0.0
                    ? 0.0
                    : (provider.successCount + provider.failureCount) /
                        provider.rulesCount;
                return Column(
                  children: [
                    SizedBox(height: 6),
                    FittedBox(
                      child: Container(
                        height: 32,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            FlatButton(
                              onPressed: null,
                              child: Text("结果过滤"),
                            ),
                            _buildFilterOpt(provider, profile, '无', SearchOption.None),
                            _buildFilterOpt(provider, profile, '普通', SearchOption.Normal),
                            _buildFilterOpt(
                                provider, profile, '精确', SearchOption.Accurate),
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
                            ),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          height: 50,
                          width: 75,
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
                        Container(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                                children: [
                                  TextSpan(text: '请求数: '),
                                  TextSpan(
                                    text: '${provider.successCount} (成功)',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  TextSpan(text: ' | '),
                                  TextSpan(
                                    text: '${provider.failureCount} (失败)',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  TextSpan(text: ' | '),
                                  TextSpan(text: '${provider.rulesCount} (总数)'),
                                  TextSpan(text: '\n'),
                                  TextSpan(
                                    text: '结果数: $count',
                                  ),
                                ],
                                style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyText1.color,
                                    height: 1.55)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Divider(height: Global.lineSize),
                    Expanded(
                      child:
                          provider.searchListNone.length == 0 && provider.rulesCount == 0
                              ? EmptyListMsgView(text: Text("尚无可搜索源"))
                              : searchList.isEmpty
                                  ? EmptyListMsgView(text: Text("没有数据哦！~"))
                                  : KeyboardDismissBehaviorView(
                                      child: ListView.separated(
                                        separatorBuilder: (context, index) =>
                                            SizedBox(height: 8),
                                        itemCount: searchList.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return InkWell(
                                            child: UiSearchItem(
                                              item: searchList[index],
                                              showType: true,
                                            ),
                                            onTap: () => Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => ChapterPage(
                                                    searchItem: searchList[index]),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                    ),
                  ],
                );
              },
            ),
          );
        });
  }

  _buildFilterOpt(
      SearchProvider provider, Profile profile, String text, SearchOption searchOption) {
    final _selected = provider.searchOption == searchOption;
    return ButtonTheme(
      height: 25,
      minWidth: 55,
      child: FlatButton(
        onPressed: () {
          provider.searchOption = searchOption;
          profile.searchOption = searchOption.index;
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: _selected
              ? BorderSide(
                  color: Theme.of(context).primaryColor, width: Global.borderSize)
              : BorderSide.none,
        ),
        child: Text(text, maxLines: 1),
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
  List<Rule> _novelRules;
  List<Rule> _mangaRules;
  List<Rule> _audioRules;
  List<Rule> _videoRules;

  final List<SearchItem> searchListNone = <SearchItem>[];
  final List<SearchItem> searchListNormal = <SearchItem>[];
  final List<SearchItem> searchListAccurate = <SearchItem>[];

  final _keys = Map<String, bool>();
  int _keySuffix;
  int _sourceType = -1;
  Profile _profile;
  SearchProvider({int threadCount, SearchOption searchOption, Profile profile}) {
    _profile = profile;
    _threadCount = threadCount ?? 10;
    _searchOption = searchOption ?? SearchOption.Normal;
    _rulesCount = 0;
    _successCount = 0;
    _failureCount = 0;
    _rules = <Rule>[];
    _keySuffix = 0;
    init();
  }

  int get sourceType => _sourceType;
  set sourceType(int value) => setSourceType(value);
  bool get novelEnableSearch => _profile.novelEnableSearch;
  bool get mangaEnableSearch => _profile.mangaEnableSearch;
  bool get audioEnableSearch => _profile.audioEnableSearch;
  bool get videoEnableSearch => _profile.videoEnableSearch;

  void updateAllSourceType(bool val) {
    _profile.novelEnableSearch = val;
    _profile.mangaEnableSearch = val;
    _profile.audioEnableSearch = val;
    _profile.videoEnableSearch = val;
  }

  void setSourceType(int type) {
    _sourceType = type;
    // 禁用所有
    updateAllSourceType(false);

    switch (type) {
      case API.NOVEL:
        _profile.novelEnableSearch = true;
        break;
      case API.MANGA:
        _profile.mangaEnableSearch = true;
        break;
      case API.AUDIO:
        _profile.audioEnableSearch = true;
        break;
      case API.VIDEO:
        _profile.videoEnableSearch = true;
        break;
      default:
        updateAllSourceType(true);
        break;
    }
    updateRules();
  }

  void updateRules() {
    if (null != _rules) {
      _rules.clear();
    } else {
      _rules = <Rule>[];
    }
    if (_profile.novelEnableSearch) {
      _rules.addAll(_novelRules);
    }
    if (_profile.mangaEnableSearch) {
      _rules.addAll(_mangaRules);
    }
    if (_profile.audioEnableSearch) {
      _rules.addAll(_audioRules);
    }
    if (_profile.videoEnableSearch) {
      _rules.addAll(_videoRules);
    }
    _rulesCount = _rules.length;
    notifyListeners();
  }

  void init() async {
    final rules =
        (await Global.ruleDao.findAllRules()).where((e) => e.enableSearch).toList();
    _novelRules = rules.where((r) => r.contentType == API.NOVEL).toList();
    _mangaRules = rules.where((r) => r.contentType == API.MANGA).toList();
    _audioRules = rules.where((r) => r.contentType == API.AUDIO).toList();
    _videoRules = rules.where((r) => r.contentType == API.VIDEO).toList();
    updateRules();
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
                  _successCount++;
                }
              });
              notifyListeners();
            } catch (e) {
              if (_keys[key]) {
                print(e);
                _failureCount++;
                notifyListeners();
              }
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
