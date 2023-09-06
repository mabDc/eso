import 'dart:ui';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_from_rule.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/rule_dao.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:eso/database/history_manager.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/ui/ui_text_field.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:eso/ui/widgets/empty_list_msg_view.dart';
import 'package:eso/ui/widgets/keyboard_dismiss_behavior_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'chapter_page.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var isLargeScreen = false;
  Widget detailPage;

  void invokeTap(Widget detailPage) {
    if (isLargeScreen) {
      this.detailPage = detailPage;
      setState(() {});
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => detailPage,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ESOTheme();
    final child = ChangeNotifierProvider(
        create: (context) => SearchProvider(
              threadCount: profile.searchCount,
              searchOption: SearchOption.values[profile.searchOption],
              profile: profile,
            ),
        builder: (context, child) {
          return Container(
            decoration: globalDecoration,
            child: Scaffold(
              appBar: AppBar(
                titleSpacing: 0,
                title: SearchTextField(
                  autofocus: true,
                  focusNode:
                      Provider.of<SearchProvider>(context, listen: false).focusNode,
                  controller: Provider.of<SearchProvider>(context, listen: false)
                      .searchController,
                  hintText: "请输入关键词",
                  prefix: Container(
                    width: 48,
                    height: 20,
                    margin: const EdgeInsets.only(left: 16, right: 12),
                    child: DropdownButton<int>(
                      iconSize: 14,
                      style: TextStyle(
                          fontSize: 13,
                          fontFamily: ESOTheme.staticFontFamily,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .color
                              .withOpacity(0.5)),
                      isExpanded: true,
                      isDense: true,
                      underline: SizedBox(),
                      onChanged: (v) =>
                          Provider.of<SearchProvider>(context, listen: false).sourceType =
                              v,
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
                      value:
                          Provider.of<SearchProvider>(context, listen: true).sourceType,
                    ),
                  ),
                  onSubmitted: Provider.of<SearchProvider>(context, listen: false).search,
                ),
                actions: [
                  SizedBox(width: 20),
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
                  if (provider.showHistory && provider.history.length > 0) {
                    return Column(
                      children: [
                        FittedBox(
                          child: Container(
                            height: 32,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: null,
                                  child: Text("结果过滤"),
                                  style: ButtonStyle(
                                      padding:
                                          MaterialStateProperty.all(EdgeInsets.zero)),
                                ),
                                _buildFilterOpt(
                                    provider, profile, '无', SearchOption.None),
                                _buildFilterOpt(
                                    provider, profile, '普通', SearchOption.Normal),
                                _buildFilterOpt(
                                    provider, profile, '精确', SearchOption.Accurate),
                                TextButton(
                                  onPressed: null,
                                  child: Text("并发数"),
                                  style: ButtonStyle(
                                      padding:
                                          MaterialStateProperty.all(EdgeInsets.zero)),
                                ),
                                Center(
                                  child: DropdownButton<int>(
                                    items: [
                                      10,
                                      20,
                                      30,
                                      40,
                                      50,
                                      60,
                                      70,
                                      80,
                                      90,
                                      100,
                                      110,
                                      120
                                    ]
                                        .map((count) => DropdownMenuItem<int>(
                                              child: Text('$count'),
                                              value: count,
                                            ))
                                        .toList(),
                                    isDense: true,
                                    underline: Container(),
                                    value: context.select((SearchProvider provider) =>
                                        provider.threadCount),
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
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: List.generate(
                            provider.history.length,
                            (int index) {
                              final String text = provider.history[index];
                              return Chip(
                                label: InkWell(
                                  child: Text(text),
                                  onTap: () {
                                    provider.searchController.text = text;
                                    provider.search(text);
                                  },
                                ),
                                onDeleted: () {
                                  // 删除操作
                                  HistoryManager.remove(text);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      SizedBox(height: 6),
                      FittedBox(
                        child: Container(
                          height: 32,
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: null,
                                child: Text("结果过滤"),
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all(EdgeInsets.zero)),
                              ),
                              _buildFilterOpt(provider, profile, '无', SearchOption.None),
                              _buildFilterOpt(
                                  provider, profile, '普通', SearchOption.Normal),
                              _buildFilterOpt(
                                  provider, profile, '精确', SearchOption.Accurate),
                              TextButton(
                                onPressed: null,
                                child: Text("并发数"),
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all(EdgeInsets.zero)),
                              ),
                              Center(
                                child: DropdownButton<int>(
                                  items:
                                      [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120]
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
                                    fontFamily: ESOTheme.staticFontFamily,
                                    color: Theme.of(context).textTheme.bodyText1.color,
                                    height: 1.55),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Divider(height: Global.lineSize),
                      Expanded(
                        child: provider.searchListNone.length == 0 &&
                                provider.rulesCount == 0
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
                                          onTap: () {
                                            // Navigator.of(context).push(
                                            // MaterialPageRoute(
                                            //   builder: (context) => ChapterPage(
                                            //       searchItem: searchList[index]),
                                            // )
                                            invokeTap(ChapterPage(
                                                searchItem: searchList[index],
                                                key: Key(index.toString())));
                                          },
                                        );
                                      },
                                    ),
                                  ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        });
    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        isLargeScreen = true;
      } else {
        isLargeScreen = false;
      }

      return Row(children: <Widget>[
        Expanded(
          child: child,
        ),
        SizedBox(
          height: double.infinity,
          width: 2,
          child: Material(
            color: Colors.grey.withAlpha(123),
          ),
        ),
        isLargeScreen ? Expanded(child: detailPage ?? Scaffold()) : Container(),
      ]);
    });
  }

  _buildFilterOpt(
      SearchProvider provider, ESOTheme profile, String text, SearchOption searchOption) {
    final _selected = provider.searchOption == searchOption;
    return Container(
      alignment: Alignment.center,
      height: 26,
      width: 50,
      margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: TextButton(
        onPressed: () {
          provider.searchOption = searchOption;
          profile.searchOption = searchOption.index;
        },
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(Size(10, 10)),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: _selected
                ? BorderSide(
                    color: Theme.of(context).primaryColor, width: Global.borderSize)
                : BorderSide.none,
          )),
        ),
        child: Text(text, maxLines: 1),
      ),
    );
  }
}

class SimpleChangeRule extends StatelessWidget {
  final SearchItem searchItem;
  const SimpleChangeRule({this.searchItem, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = ESOTheme();
    return Scaffold(
      appBar: AppBar(
        title: Text("${searchItem.name} (${searchItem.author})"),
      ),
      body: ChangeNotifierProvider(
        create: (context) => SearchProvider(
          threadCount: profile.searchCount,
          searchOption: SearchOption.Accurate,
          profile: profile,
          ruleContentType: searchItem.ruleContentType,
          searchKey: searchItem.name,
        ),
        builder: (context, child) {
          return Consumer<SearchProvider>(
            builder: (context, provider, child) {
              final searchList = provider.searchListAccurate;
              final count = searchList.length;
              final progress = provider.rulesCount == 0.0
                  ? 0.0
                  : (provider.successCount + provider.failureCount) / provider.rulesCount;
              return Column(
                children: [
                  SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                  SizedBox(
                    height: 20,
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
                          TextSpan(text: ' | ${provider.rulesCount} (总数) | 结果数: $count'),
                        ],
                        style: TextStyle(
                            fontFamily: ESOTheme.staticFontFamily,
                            color: Theme.of(context).textTheme.bodyText1.color,
                            height: 1.55),
                      ),
                    ),
                  ),
                  Expanded(
                    child: provider.rulesCount == 0
                        ? EmptyListMsgView(text: Text("尚无可搜索源"))
                        : searchList.isEmpty
                            ? EmptyListMsgView(text: Text("没有数据哦！~"))
                            : ListView.separated(
                                separatorBuilder: (context, index) => SizedBox(height: 8),
                                itemCount: searchList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    child: UiSearchItem(
                                      item: searchList[index],
                                      showType: true,
                                    ),
                                    onTap: () =>
                                        Navigator.of(context).pop(searchList[index]),
                                  );
                                },
                              ),
                  ),
                ],
              );
            },
          );
        },
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

  int _searchId;
  int _sourceType = -1;
  ESOTheme _profile;
  FocusNode _focusNode;
  FocusNode get focusNode => _focusNode;
  TextEditingController _searchController;
  TextEditingController get searchController => _searchController;
  List<String> _history;
  List<String> get history => _history;
  bool _showHistory;
  bool get showHistory => false; //_showHistory;
  SearchProvider({
    int threadCount,
    SearchOption searchOption,
    ESOTheme profile,
    String searchKey,
    int ruleContentType,
  }) {
    _profile = profile;
    _threadCount = threadCount ?? profile.searchCount ?? 10;
    _searchOption = searchOption ?? SearchOption.Normal;
    _rulesCount = 0;
    _successCount = 0;
    _failureCount = 0;
    _rules = <Rule>[];
    _searchId = 0;
    _showHistory = true;
    _searchController = TextEditingController()..addListener(_handleSearchChange);
    _history = List.from(HistoryManager.searchHistory);
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    APIFromRUle.clearNextUrl();
    init(ruleContentType, searchKey);
  }

  void _handleSearchChange() {
    final text = _searchController.text.trim();
    _history =
        HistoryManager.searchHistory.where((element) => element.contains(text)).toList();
    notifyListeners();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _history.clear();
      final text = _searchController.text.trim();
      _history = HistoryManager.searchHistory
          .where((element) => element.contains(text))
          .toList();
      _showHistory = true;
      notifyListeners();
    } else {
      Future.delayed(Duration(milliseconds: 100), closeHistory);
    }
  }

  void closeHistory() {
    _showHistory = false;
    _focusNode.unfocus();
    notifyListeners();
  }

  void upHistory(String keyword) {
    _searchController.text = keyword;
    _searchController.selection =
        TextSelection(baseOffset: keyword.length, extentOffset: keyword.length);
  }

  void clearHistory() {
    HistoryManager.clear();
    notifyListeners();
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
    var enableCount = 0;
    if (_profile.novelEnableSearch) {
      enableCount++;
      _sourceType = API.NOVEL;
      _rules.addAll(_novelRules);
    }
    if (_profile.mangaEnableSearch) {
      enableCount++;
      _sourceType = API.MANGA;
      _rules.addAll(_mangaRules);
    }
    if (_profile.audioEnableSearch) {
      enableCount++;
      _sourceType = API.AUDIO;
      _rules.addAll(_audioRules);
    }
    if (_profile.videoEnableSearch) {
      enableCount++;
      _sourceType = API.VIDEO;
      _rules.addAll(_videoRules);
    }
    if (enableCount > 1) {
      _sourceType = -1;
    }
    _rulesCount = _rules.length;
    notifyListeners();
  }

  void init(int ruleContentType, String searchKey) async {
    await RuleDao.gaixieguizheng();
    final rules =
        (await Global.ruleDao.findAllRules()).where((e) => e.enableSearch).toList();

    _novelRules = rules.where((r) => r.contentType == API.NOVEL).toList();
    _mangaRules = rules.where((r) => r.contentType == API.MANGA).toList();
    _audioRules = rules.where((r) => r.contentType == API.AUDIO).toList();
    _videoRules = rules.where((r) => r.contentType == API.VIDEO).toList();

    if (ruleContentType != null) {
      _rules = rules.where((r) => r.contentType == ruleContentType).toList();
      _rulesCount = _rules.length;
      _sourceType = ruleContentType;
      notifyListeners();
    } else {
      updateRules();
    }
    if (searchKey != null) {
      search(searchKey);
    }
  }

  void search(String keyword) async {
    focusNode.unfocus();
    _searchController.text = keyword;
    HistoryManager.newSearch(keyword);
    _searchId++;
    await Future.delayed(Duration(milliseconds: 300));
    searchListNone.clear();
    searchListNormal.clear();
    searchListAccurate.clear();
    _successCount = 0;
    _failureCount = 0;
    notifyListeners();
    for (var i = 0; i < threadCount; i++) {
      final count = _rules.length - 1 - i;
      final realCount = count < 0 ? 0 : count ~/ threadCount + 1;
      ((int searchId) async {
        for (var j = 0; j < realCount; j++) {
          final engineId = j * threadCount + i;
          if (_searchId == searchId) {
            try {
              print(j * threadCount + i);
              (await APIFromRUle(_rules[engineId], searchId * 10000 + engineId)
                      .search(keyword, 1, 20))
                  .forEach((item) {
                if (_searchId == searchId) {
                  searchListNone.add(item);
                  if (item.name?.contains(keyword) == true ||
                      item.author?.contains(keyword) == true) {
                    searchListNormal.add(item);
                    if (item.name == keyword || item.author == keyword) {
                      searchListAccurate.add(item);
                    }
                  }
                }
              });
              if (_searchId == searchId) {
                _successCount++;
                notifyListeners();
              }
            } catch (e) {
              if (_searchId == searchId) {
                _failureCount++;
                print("error   !!!       " * 10);
                print(_rules[j * threadCount + i].name);
                notifyListeners();
              }
            }
          }
        }
      })(_searchId);
    }
  }

  @override
  void dispose() {
    _searchId = null;
    searchListNone.clear();
    searchListNormal.clear();
    searchListAccurate.clear();
    _focusNode.removeListener(_handleSearchChange);
    _searchController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    APIFromRUle.clearNextUrl();
    super.dispose();
  }
}
