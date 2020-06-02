import 'dart:ui';

import 'package:eso/api/api.dart';
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
        profile: profile,
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
            final searchList = provider.searchOption == SearchOption.None
                ? provider.searchListNone
                : provider.searchOption == SearchOption.Normal
                    ? provider.searchListNormal
                    : provider.searchListAccurate;
            final count = searchList.length;
            final progress = provider.rulesCount == 0.0
                ? 0.0
                : (provider.successCount + provider.failureCount) / provider.rulesCount;
            return Column(
              children: [
                FittedBox(
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        FlatButton(
                          onPressed: null,
                          child: Text("规则选择"),
                        ),
                        Checkbox(
                          value: provider.novelEnableSearch,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (value) => provider.novelEnableSearch = value,
                        ),
                        Text(API.getRuleContentTypeName(API.NOVEL)),
                        Checkbox(
                          value: provider.mangaEnableSearch,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (value) => provider.mangaEnableSearch = value,
                        ),
                        Text(API.getRuleContentTypeName(API.MANGA)),
                        Checkbox(
                          value: provider.audioEnableSearch,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (value) => provider.audioEnableSearch = value,
                        ),
                        Text(API.getRuleContentTypeName(API.AUDIO)),
                        Checkbox(
                          value: provider.videoEnableSearch,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (value) => provider.videoEnableSearch = value,
                        ),
                        Text(API.getRuleContentTypeName(API.VIDEO)),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
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
                        InkWell(
                          onTap: () {
                            provider.searchOption = SearchOption.None;
                            profile.searchOption = SearchOption.None.index;
                          },
                          child: Container(
                            width: 55,
                            alignment: Alignment.center,
                            child: Text(
                              "无",
                              style: provider.searchOption == SearchOption.None
                                  ? TextStyle(color: theme.primaryColor)
                                  : TextStyle(),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            provider.searchOption = SearchOption.Normal;
                            profile.searchOption = SearchOption.Normal.index;
                          },
                          child: Container(
                            width: 55,
                            alignment: Alignment.center,
                            child: Text(
                              "普通",
                              style: provider.searchOption == SearchOption.Normal
                                  ? TextStyle(color: theme.primaryColor)
                                  : TextStyle(),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            provider.searchOption = SearchOption.Accurate;
                            profile.searchOption = SearchOption.Accurate.index;
                          },
                          child: Container(
                            width: 55,
                            alignment: Alignment.center,
                            child: Text(
                              "精确",
                              style: provider.searchOption == SearchOption.Accurate
                                  ? TextStyle(color: theme.primaryColor)
                                  : TextStyle(),
                            ),
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
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                Center(
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
                      Container(
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
                    ],
                  ),
                ),
                Expanded(
                  child: provider.searchListNone.length == 0 && provider.rulesCount == 0
                      ? Center(child: Text('尚无可搜索源'))
                      : ListView.separated(
                          padding: EdgeInsets.all(8),
                          separatorBuilder: (context, index) => SizedBox(height: 8),
                          itemCount: searchList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              child: UiSearchItem(
                                item: searchList[index],
                                showType: true,
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChapterPage(searchItem: searchList[index]),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
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
  List<Rule> _novelRules;
  List<Rule> _mangaRules;
  List<Rule> _audioRules;
  List<Rule> _videoRules;

  final List<SearchItem> searchListNone = <SearchItem>[];
  final List<SearchItem> searchListNormal = <SearchItem>[];
  final List<SearchItem> searchListAccurate = <SearchItem>[];

  final _keys = Map<String, bool>();
  int _keySuffix;
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

  bool get novelEnableSearch => _profile.novelEnableSearch;
  bool get mangaEnableSearch => _profile.mangaEnableSearch;
  bool get audioEnableSearch => _profile.audioEnableSearch;
  bool get videoEnableSearch => _profile.videoEnableSearch;

  set novelEnableSearch(bool value) {
    if (value != _profile.novelEnableSearch) {
      _profile.novelEnableSearch = value;
      updateRules();
    }
  }

  set mangaEnableSearch(bool value) {
    if (value != _profile.mangaEnableSearch) {
      _profile.mangaEnableSearch = value;
      updateRules();
    }
  }

  set audioEnableSearch(bool value) {
    if (value != _profile.audioEnableSearch) {
      _profile.audioEnableSearch = value;
      updateRules();
    }
  }

  set videoEnableSearch(bool value) {
    if (value != _profile.videoEnableSearch) {
      _profile.videoEnableSearch = value;
      updateRules();
    }
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