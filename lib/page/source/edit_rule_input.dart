import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

enum RuleRowType {
  debugRule,
  MoreKeys,
  basicName,
  basicHost,
  basicAuthor,
  basicType,
  basicMore,
  otherIcon,
  otherGrop,
  otherDesc,
  otherLoginUrl,
  otherUserAgent,
  otherCookies,
  otherpostScript,
  otherloadScript,
  commonSearch,
  commonDiscover,
  commonChapter,
  commonContent,
  searchUrl,
  searchList,
  searchName,
  searchCover,
  searchAuthor,
  searchChapter,
  searchDescription,
  searchResult,
  searchTags,
  searchNextUrl,
  discoverUrl,
  discoverList,
  discoverNextUrl,
  discoverName,
  discoverAuthor,
  discoverCover,
  discoverChapter,
  discoverDescription,
  discoverTags,
  discoverResultUrl,
  chapterUrl,
  chapterNextUrl,
  chapterRoads,
  chapterRoadName,
  chapterList,
  chapterName,
  chapterCover,
  chapterLock,
  chapterTime,
  chapterResult,
  contentUrl,
  contentNextUrl,
  contentItems,
  contentDecrypt,
}

String getEditRuleTypeName(RuleRowType type) {
  switch (type) {
    case RuleRowType.basicHost:
      return '域名(host)';
    case RuleRowType.basicName:
      return '名称';
    case RuleRowType.basicAuthor:
      return '作者';
    case RuleRowType.otherIcon:
      return '图标URL';
    case RuleRowType.otherCookies:
      return 'Cookies';
    case RuleRowType.otherDesc:
      return '规则简介';
    case RuleRowType.otherGrop:
      return '分组';
    case RuleRowType.otherLoginUrl:
      return '登陆URL';
    case RuleRowType.otherUserAgent:
      return 'UserAgent';
    case RuleRowType.otherloadScript:
      return '加载的JS脚本';
    case RuleRowType.otherpostScript:
      return 'PostScript';
    case RuleRowType.searchUrl:
      return '地址Url';
    case RuleRowType.searchList:
      return '搜索列表(list)';
    case RuleRowType.searchName:
      return '名称(name)';
    case RuleRowType.searchAuthor:
      return '作者(author)';
    case RuleRowType.searchCover:
      return '封面(cover)';
    case RuleRowType.searchChapter:
      return '最新章节(lastChapter)';
    case RuleRowType.searchResult:
      return '结果(resultUrl)';
    case RuleRowType.searchDescription:
      return '简介(desc)';
    case RuleRowType.searchTags:
      return '标签(tags)';
    case RuleRowType.searchNextUrl:
      return '下一页URL(nextPageUrl)';
    case RuleRowType.discoverUrl:
      return '地址Url(discoverUrl)';
    case RuleRowType.discoverList:
      return '发现列表(list)';
    case RuleRowType.discoverNextUrl:
      return '下一页URL(nextPageUrl)';
    case RuleRowType.discoverName:
      return '名称(name)';
    case RuleRowType.discoverAuthor:
      return '作者(author)';
    case RuleRowType.discoverCover:
      return '封面(cover)';
    case RuleRowType.discoverTags:
      return '标签(tags)';
    case RuleRowType.discoverChapter:
      return '最新章节(lastChapter)';
    case RuleRowType.discoverResultUrl:
      return '结果Url(resultUrl)';
    case RuleRowType.MoreKeys:
      return '更多键(moreKeys)';

    case RuleRowType.chapterCover:
      return '章节封面(cover)';
    case RuleRowType.chapterList:
      return '章节列表(chapterList)';
    case RuleRowType.chapterLock:
      return '章节状态(status)';
    case RuleRowType.chapterName:
      return '章节名称(name)';
    case RuleRowType.chapterNextUrl:
      return '下一页Url(nextPageUrl)';
    case RuleRowType.chapterResult:
      return '结果Url(resultUrl)';
    case RuleRowType.chapterRoadName:
      return '线路名(roadName)';
    case RuleRowType.chapterRoads:
      return '线路(roads)';
    case RuleRowType.chapterTime:
      return '更新时间(chapterTime)';
    case RuleRowType.chapterUrl:
      return '地址Url(chapterUrl)';
    case RuleRowType.contentUrl:
      return '地址Url(contentUrl)';
    case RuleRowType.contentNextUrl:
      return '下一页Url(nextPageUrl)';
    case RuleRowType.contentItems:
      return '正文(content)';
    case RuleRowType.contentDecrypt:
      return '图片解密规则(decrypt)';

    default:
      return '';
      break;
  }
}

class EditRuleInput extends StatefulWidget {
  final bool isBottomSheet;
  final RuleRowType ruleRowType;
  final TextEditingController textEditingController;
  const EditRuleInput(
      {@required this.ruleRowType,
      @required this.textEditingController,
      bool this.isBottomSheet = false,
      Key key})
      : super(key: key);
  @override
  State<EditRuleInput> createState() => _EditRuleInputState();
}

class _EditRuleInputState extends State<EditRuleInput> {
  /// 快速输入符号List
  final inputList = [
    {
      'encoding': '"encoding":"gbk"',
      'async': r'''
(async() => {
    
    return '';
})();''',
      'http': r'''var html = await http('');''',
      'xpath': r'''var x = await xpath(html, '//*[@class="xx"]');''',
      'xpath_class': '//*[@class="xx"]',
      'xpath_id': '//*[@id="xx"]',
      'match': "result.match(/xx/)[0];",
      'stringify': "JSON.stringify({});",
      'parse': "JSON.parse(xx);",
      'get-gbk': r'''{
    "url": "/modules/article/search.php?searchkey=$keyword&searchtype=articlename&page=$page",
    "encoding": "gbk"
}''',
      'get-headers': r'''{
    "url": "/modules/article/search.php?searchkey=$keyword&searchtype=articlename&page=$page",
    "headers":{
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36 Edg/100.0.1185.29"
    }
}''',
      'post-form1': r'''{
    "url": "/modules/article/search.php",
    "method": "POST",
    "body": "searchkey=$keyword&searchtype=articlename",
    "headers": {
        "Content-Type": "application/x-www-form-urlencoded"
    }
}''',
      'post-form2': r'''{
    "url": "/modules/article/search.php",
    "method": "POST",
    "body": {
        "searchkey": "$keyword",
        "searchtype": "articlename"
    }
}''',
      'post-json': r'''{
    "url": "/modules/article/search.php",
    "method": "POST",
    "body": "{\"searchkey\": \"$keyword\",\"searchtype\": \"articlename\"}",
    "headers":{
        "Content-Type": "application/json"
    }
}''',
      'post-headers': r'''{
    "url": "/modules/article/search.php",
    "method": "POST",
    "body": "searchkey=$keyword&searchtype=articlename",
    "headers": {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36 Edg/84.0.522.40"
    }
}''',
      'Macintosh-UA':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36',
      'Android-UA':
          'Mozilla/5.0 (Linux; Android 9; MIX 2 Build/PKQ1.190118.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/80.0.3987.99 Mobile Safari/537.36',
    },
    {
      '`': '`',
      '"': '"',
      '\'': '\'',
      '@': '@',
      ':': ':',
      '&': '&',
      '|': '|',
      '%': '%',
      '/': '/',
      '\\': '\\',
      '[': '[',
      ']': ']',
      '{': '{',
      '}': '}',
      '<': '<',
      '>': '>',
      '\$': '\$',
      '.': '.',
      '#': '#',
      'keyword': 'keyword',
      'page': 'page',
      'pageSize': 'pageSize',
      'host': 'host',
      'result': 'result',
      'lastResult': 'lastResult',
      'text': 'text',
      'href': 'href',
      'src': 'src',
      'headers': 'headers',
      'User-Agent': 'User-Agent',
    }
  ];

  TextEditingController currentController;
  void Function(String text) currentOnChanged;
  FocusNode focusNode;

  Widget _buildInputHelp(Map<String, String> inputList) {
    final inputKeys = inputList.keys.toList();
    final inputValues = inputList.values.toList();
    return Container(
      height: 32,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: inputKeys.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                inputKeys[index],
                style: TextStyle(fontSize: 16, height: 2),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () {
              final fastText = inputValues[index];
              final textSelection = currentController.selection;
              currentController.text = currentController.text.replaceRange(
                textSelection.start,
                textSelection.end,
                fastText,
              );
              currentOnChanged(currentController.text);
              currentController.selection = textSelection.copyWith(
                baseOffset: textSelection.end + fastText.length,
                extentOffset: textSelection.end + fastText.length,
              );
            },
          );
        },
      ),
    );
  }

  onchange(String s) {
    widget.textEditingController?.text = s;
  }

  // ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(() {
    //   // _scrollController.offset

    //   if (focusNode.hasFocus) {
    //     focusNode.unfocus();
    //   }

    // });
    focusNode = FocusNode()
      ..addListener(() {
        print("object");

        currentController = widget.textEditingController;
        currentOnChanged = onchange;
      });
  }

  @override
  void dispose() {
    focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        // backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          // transitionBetweenRoutes: false,
          border: null,
          middle: Text(
            getEditRuleTypeName(widget.ruleRowType),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 21),
          ),
          // backgroundColor: CupertinoDynamicColor.withBrightness(
          //   color: Color(0xF0F9F9F9),
          //   darkColor: Color(0xF01D1D1D),
          // ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                height: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8)
                    .copyWith(bottom: 60),
                child: CupertinoTextField(
                  focusNode: focusNode,
                  autocorrect: true,
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.withBrightness(
                      color: CupertinoColors.white,
                      darkColor: Color.fromARGB(255, 15, 15, 15),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(1.0)),
                  ),
                  // autofocus: true,
                  controller: widget.textEditingController,
                  maxLines: null,
                ),
              ),

              Positioned(
                bottom: 0,
                child: Column(
                  children:
                      inputList.map((list) => _buildInputHelp(list)).toList(),
                ),
              ),

              // ...inputList.map((list) => _buildInputHelp(list)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
