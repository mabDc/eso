import 'dart:convert';
import 'dart:io';

import 'package:eso/api/analyze_url_client.dart';
import 'package:eso/api/api_js_engine.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/rule_dao.dart';
import 'package:eso/global.dart';
import 'package:eso/menu/menu.dart';
import 'package:eso/menu/menu_edit_rule.dart';
import 'package:eso/menu/menu_edit_source.dart';
import 'package:eso/model/debug_rule_provider.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/page/source/edit_rule_input.dart';
import 'package:eso/profile.dart';
import 'package:eso/page/source/debug_rule_page.dart';
import 'package:eso/ui/round_indicator.dart';
import 'package:eso/ui/widgets/draggable_scrollbar_sliver.dart';
import 'package:eso/ui/widgets/form_section.dart';
import 'package:eso/ui/widgets/keep_alive_widget.dart';
import 'package:eso/ui/widgets/keyboard_dismiss_behavior_view.dart';
import 'package:eso/ui/widgets/size_bar.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/rule_comparess.dart';
import 'package:cupertino_tabbar/cupertino_tabbar.dart';
import 'package:flutter/cupertino.dart'
    hide CupertinoTabBar
    hide CupertinoFormSection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/api.dart';
import '../../fonticons_icons.dart';
import '../discover_page.dart';
import 'login_rule_page.dart';
import 'editor/highlight_code_editor.dart';

class JsDebug extends StatefulWidget {
  final Rule rule;
  final FocusNode focusNode;
  const JsDebug({this.rule, this.focusNode, Key key}) : super(key: key);

  @override
  State<JsDebug> createState() => _JsDebugState();
}

class _JsDebugState extends State<JsDebug> {
  GlobalKey<HighLightCodeEditorState> codeKey = GlobalKey();
  String s = "";
  bool isNotCollapsed = false;
  String code = "";
  TextEditingController currentController;
  void Function(String text) currentOnChanged;
  onchangeCode(String s) {
    code = s;
    codeKey.currentState?.codeTextController?.text = s;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Positioned(
        top: isNotCollapsed ? 1 : null,
        right: 10,
        bottom: 20,
        child: Container(
          width: isNotCollapsed ? size.width - 10 : null,
          constraints: isNotCollapsed
              ? BoxConstraints(maxHeight: size.height - 150 - bottom)
              : null,
          child: Card(
            child: isNotCollapsed
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: HighLightCodeEditor(
                          codeKey,
                          code,
                          // focusNode: widget.focusNode,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(child: SelectableText(s)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(text: s));
                              Utils.toast("已复制结果");
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("复制结果"),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(
                                  text: codeKey.currentState?.code ?? code));
                              Utils.toast("已复制代码");
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("复制代码"),
                            ),
                          ),
                          InkWell(
                            onTap: () => codeKey.currentState?.format(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("格式化"),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              try {
                                await JSEngine.setEnvironment(1, widget.rule,
                                    "", widget.rule.host, "", "");
                                final x = await JSEngine.evaluate(
                                    codeKey.currentState?.code ?? code);
                                setState(() {
                                  s = "$x";
                                });
                              } catch (e, st) {
                                setState(() {
                                  s = "$e\n$st";
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("运行"),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              code = codeKey.currentState?.code ?? code;
                              setState(() => isNotCollapsed = !isNotCollapsed);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("折叠"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : InkWell(
                    onTap: () {
                      code = codeKey.currentState?.code ?? code;
                      setState(() => isNotCollapsed = !isNotCollapsed);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      child: Text("JS测试"),
                    ),
                  ),
          ),
        ));
  }
}

class DebugRuleNew extends StatelessWidget {
  final Rule rule;
  final int type;
  final Map<String, SearchLists> debugRuleResult;

  const DebugRuleNew({this.rule, this.type, this.debugRuleResult, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChangeNotifierProvider<DebugRuleProvider>(
        create: (_) => DebugRuleProvider(
          this.rule,
          Theme.of(context).textTheme.bodyLarge.color,
          type: type,
          debugRuleResult: debugRuleResult,
        ),
        builder: (context, child) {
          final isDark = Utils.isDarkMode(context);

          return Consumer<DebugRuleProvider>(builder: (context, provider, _) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                transitionBetweenRoutes: false,
                automaticallyImplyLeading: false,
                middle: CupertinoTabBar(
                  isDark ? Color.fromARGB(255, 8, 7, 22) : Color(0xFFd4d7dd),
                  isDark ? const Color(0xF05A5A5F) : Color(0xFFf7f7f7),
                  [
                    Text(
                      "参数",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "响应",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "解析",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "协议",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  () => provider.cupertinoTabBarValue,
                  (int index) {
                    provider.cupertinoTabBarValue = index;
                    provider.focusNode.unfocus();
                  },
                  innerVerticalPadding: 5.0,
                  useShadow: false,
                  // innerHorizontalPadding: 5,
                ),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text("请求"),
                  onPressed: () async {
                    final provider =
                        Provider.of<DebugRuleProvider>(context, listen: false);

                    provider.focusNode.unfocus();
                    switch (this.type) {
                      // 发现
                      case 0:
                        provider.cupertinoTabBarValue = 2;
                        await provider.discover(isParseChapter: false);
                        this.debugRuleResult['searchList'] =
                            provider.searchList;

                        break;
                      // 搜索
                      case 1:
                        provider.cupertinoTabBarValue = 2;
                        await provider.search('', isParseChapter: false);
                        this.debugRuleResult['searchList'] =
                            provider.searchList;

                        print(
                            "provider.searchList:${provider.searchList.resultUrl}");

                        break;
                      case 2:
                        // final searchList = this.debugRuleResult['searchList'] ??
                        //     SearchLists(resultUrl: null, url: null);
                        provider.cupertinoTabBarValue = 2;
                        final params =
                            jsonDecode(provider.paramEditController.text);
                        final detaiUrl = params['detaiUrl'] ?? '';

                        await provider.parseChapter(detaiUrl,
                            isPraseContent: false);
                        this.debugRuleResult['chapterList'] =
                            provider.chapterList;

                        break;

                      case 3:
                        provider.cupertinoTabBarValue = 2;
                        final params =
                            jsonDecode(provider.paramEditController.text);
                        final requstUrl = params['requstUrl'] ?? '';

                        await provider.praseContent(requstUrl, isParse: true);

                        break;

                      default:
                    }

                    // this.debugRuleResultWithNew.requestUrl = provider.discoverList.;
                    // this.debugRuleResultWithNew.result = provider.requestResult;
                  },
                ),
                // leading: Text("测试"),
              ),
              child: SafeArea(
                bottom: false,
                child: IndexedStack(
                  index: provider.cupertinoTabBarValue,
                  children: [
                    Container(
                      height: double.infinity,
                      child: CupertinoTextField.borderless(
                        focusNode: provider.focusNode,
                        // expands: true,
                        controller: provider.paramEditController,
                        maxLines: null,
                      ),
                    ),
                    Container(
                      height: double.infinity,
                      child: CupertinoScrollbar(
                        controller: provider.scrollControllerRaw,
                        child: CupertinoTextField.borderless(
                          controller: provider.rawEditController,
                          scrollController: provider.scrollControllerRaw,
                          readOnly: true,
                          maxLines: null,
                        ),
                      ),
                    ),
                    CupertinoScrollbar(
                      controller: provider.controller,
                      child: ListView.builder(
                        controller: provider.controller,
                        padding: EdgeInsets.all(8),
                        itemCount: provider.rows.length,
                        itemBuilder: (BuildContext context, int index) {
                          return provider.rows[index];
                        },
                      ),
                    ),

                    httpLog.urls.isEmpty
                        ? Container()
                        : CupertinoScrollbar(
                            controller: provider.scrollControllerProtocol,
                            child: CupertinoTextField.borderless(
                              controller: TextEditingController(
                                  text:
                                      "请求地址:\n${httpLog.GetUrls()}\n\n\n原始请求:\n${httpLog.GetOriginalRequest()}\n\n\n当前请求:\n${httpLog.GetCurrentRequest()}\n\n\n原始响应:\n${httpLog.GetOriginalResponse()}\n\n\n当前响应 :\n${httpLog.GetCurrentResponse()}"),
                              scrollController:
                                  provider.scrollControllerProtocol,
                              readOnly: true,
                              maxLines: null,
                            )),
                    // Text("请求协议"),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class EditRuleWithMoreConfig extends StatefulWidget {
  final Rule rule;
  const EditRuleWithMoreConfig({@required this.rule, Key key})
      : super(key: key);

  @override
  State<EditRuleWithMoreConfig> createState() => _EditRuleWithMoreConfigState();
}

class _EditRuleWithMoreConfigState extends State<EditRuleWithMoreConfig> {
  final _textEditingController = TextEditingController();

  Widget _buildFromRow(BuildContext context2,
      {String name,
      String prefix,
      RuleRowType ruleRowType,
      void Function() onComplete}) {
    return InkWell(
      onTap: () async {
        _textEditingController.text = Utils.empty(name) ? '' : name;
        Navigator.of(context2)
            .push(CupertinoPageRoute(
                builder: (context) => EditRuleInput(
                    isBottomSheet: true,
                    ruleRowType: ruleRowType,
                    textEditingController: _textEditingController)))
            .whenComplete(() => setState(() => onComplete()));
      },
      child: CupertinoFormRow(
        padding:
            EdgeInsets.symmetric(vertical: 10).copyWith(left: 20, right: 10),
        prefix: Text(prefix),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 10),
            Expanded(
                child: Text(
              Utils.empty(name) ? '' : name,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              // style: TextStyle(fontSize: 14),
            )),
            SizedBox(width: 5),
            Icon(CupertinoIcons.right_chevron, size: 15),
            SizedBox(width: 5)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext rootContext) {
    return Material(
      child: WillPopScope(
        onWillPop: null,
        child: Navigator(
          onGenerateRoute: (_) => CupertinoPageRoute(
            builder: (context2) => Builder(
              builder: (context) => CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  automaticallyImplyLeading: false,
                  // previousPageTitle: "更多配置",
                  middle: Text("更多配置"),
                  border: null,
                ),
                child: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            // SizedBox(height: 50),
                            CupertinoFormSection(
                              headerPadding: EdgeInsetsDirectional.zero,
                              header: Text("启用控制"),
                              children: [
                                CupertinoFormRow(
                                  prefix: Text("启用发现"),
                                  child: CupertinoSwitch(
                                      value: widget.rule.enableDiscover,
                                      onChanged: (value) {
                                        widget.rule.enableDiscover = value;
                                        setState(() => null);
                                      }),
                                ),
                                CupertinoFormRow(
                                  prefix: Text("启用搜索"),
                                  child: CupertinoSwitch(
                                      value: widget.rule.enableSearch,
                                      onChanged: (value) {
                                        widget.rule.enableSearch = value;
                                        setState(() => null);
                                      }),
                                ),
                                CupertinoFormRow(
                                  prefix: Text("允许上传"),
                                  child: CupertinoSwitch(
                                      value: widget.rule.enableUpload,
                                      onChanged: (value) {
                                        widget.rule.enableUpload = value;
                                        setState(() => null);
                                      }),
                                ),
                              ],
                            ),
                            CupertinoFormSection(
                              headerPadding: EdgeInsetsDirectional.zero,
                              header: Text("其他配置"),
                              children: [
                                _buildFromRow(context2,
                                    ruleRowType: RuleRowType.otherIcon,
                                    name: widget.rule.icon,
                                    prefix: '图标URL',
                                    onComplete: () => widget.rule.icon =
                                        _textEditingController.text),
                                _buildFromRow(context2,
                                    ruleRowType: RuleRowType.otherGrop,
                                    name: widget.rule.group,
                                    prefix: '分组',
                                    onComplete: () => widget.rule.group =
                                        _textEditingController.text),
                                _buildFromRow(context2,
                                    ruleRowType: RuleRowType.otherDesc,
                                    name: widget.rule.desc,
                                    prefix: '规则简介',
                                    onComplete: () => widget.rule.desc =
                                        _textEditingController.text),
                                _buildFromRow(context2,
                                    ruleRowType: RuleRowType.otherloadScript,
                                    name: widget.rule.loadJs,
                                    prefix: '加载JS',
                                    onComplete: () => widget.rule.loadJs =
                                        _textEditingController.text),
                                _buildFromRow(context2,
                                    ruleRowType: RuleRowType.otherUserAgent,
                                    name: widget.rule.userAgent,
                                    prefix: 'UserAgent',
                                    onComplete: () => widget.rule.userAgent =
                                        _textEditingController.text),
                                _buildFromRow(context2,
                                    ruleRowType: RuleRowType.otherLoginUrl,
                                    name: widget.rule.loginUrl,
                                    prefix: '登陆地址',
                                    onComplete: () => widget.rule.loginUrl =
                                        _textEditingController.text),
                                _buildFromRow(context2,
                                    ruleRowType: RuleRowType.otherCookies,
                                    name: widget.rule.cookies,
                                    prefix: 'Cookies',
                                    onComplete: () => widget.rule.cookies =
                                        _textEditingController.text),
                                _buildFromRow(context2,
                                    ruleRowType: RuleRowType.otherpostScript,
                                    name: widget.rule.postScript,
                                    prefix: 'postScript',
                                    onComplete: () => widget.rule.postScript =
                                        _textEditingController.text),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditRuleSearch extends StatefulWidget {
  final Rule rule;
  final Map<String, SearchLists> debugRuleResult;
  const EditRuleSearch({this.rule, this.debugRuleResult, Key key})
      : super(key: key);
  @override
  State<EditRuleSearch> createState() => _EditRuleSearchState();
}

class _EditRuleSearchState extends State<EditRuleSearch> {
  final _textEditingController = TextEditingController();

  Widget _buildFromRow(BuildContext context2,
      {String name,
      String prefix,
      RuleRowType ruleRowType,
      void Function() onComplete,
      bool indent = false}) {
    final child = InkWell(
        onTap: () async {
          _textEditingController.text = Utils.empty(name) ? '' : name;
          Navigator.of(context2)
              .push(CupertinoPageRoute(
                  builder: (context) => EditRuleInput(
                        ruleRowType: ruleRowType,
                        textEditingController: _textEditingController,
                        // isBottomSheet: true,
                      )))
              .whenComplete(() => setState(() => onComplete()));
        },
        child: CupertinoFormRow(
          padding: indent
              ? null
              : EdgeInsets.symmetric(vertical: 10)
                  .copyWith(left: 20, right: 10),
          prefix: Text(prefix),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                Utils.empty(name) ? '' : name,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: CupertinoTheme.of(context).textTheme.textStyle,
                // style: TextStyle(fontSize: 14),
              )),
              SizedBox(width: 5),
              Icon(CupertinoIcons.right_chevron, size: 15),
              SizedBox(width: 5)
            ],
          ),
        ));

    return indent ? CupertinoFormRow(child: child) : child;
  }

  @override
  Widget build(BuildContext context) {
    final editSourceProvider =
        Provider.of<EditSourceProvider>(context, listen: false);

    return Material(
      child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            // previousPageTitle: "更多配置",
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text("保存"),
              onPressed: () {
                Utils.toast("开始保存");
                editSourceProvider
                    .handleSelect([widget.rule], MenuEditSource.save);
              },
            ),
            middle: Text("搜索规则"),
            border: null,
          ),
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text("请求地址规则"),
                      children: [
                        _buildFromRow(
                          context,
                          ruleRowType: RuleRowType.searchUrl,
                          prefix: "地址(searchUrl)",
                          name: widget.rule.searchUrl,
                          onComplete: () => widget.rule.searchUrl =
                              _textEditingController.text,
                        ),
                      ],
                    ),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text("搜索响应规则"),
                      children: [
                        _buildFromRow(
                          context,
                          ruleRowType: RuleRowType.searchList,
                          prefix: "列表(searchList)",
                          name: widget.rule.searchList,
                          onComplete: () => widget.rule.searchList =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.searchNextUrl,
                          prefix: "下一页(nextPageUrl)",
                          name: widget.rule.searchNextUrl,
                          onComplete: () => widget.rule.searchNextUrl =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.searchName,
                          prefix: "名称(name)",
                          name: widget.rule.searchName,
                          onComplete: () => widget.rule.searchName =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.searchAuthor,
                          prefix: "作者(author)",
                          name: widget.rule.searchAuthor,
                          onComplete: () => widget.rule.searchAuthor =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.searchCover,
                          prefix: "封面(cover)",
                          name: widget.rule.searchCover,
                          onComplete: () => widget.rule.searchCover =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.searchChapter,
                          prefix: "最新章节(lastChapter)",
                          name: widget.rule.searchChapter,
                          onComplete: () => widget.rule.searchChapter =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.searchTags,
                          prefix: "标签(tags)",
                          name: widget.rule.searchTags,
                          onComplete: () => widget.rule.searchTags =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.searchDescription,
                          prefix: "简介(desc)",
                          name: widget.rule.searchDescription,
                          onComplete: () => widget.rule.searchDescription =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.searchChapter,
                          prefix: "结果地址(resultUrl)",
                          name: widget.rule.searchResult,
                          onComplete: () => widget.rule.searchResult =
                              _textEditingController.text,
                        ),
                      ],
                    ),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text('手动解析'),
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => Utils.toast("没写"),
                          child: CupertinoFormRow(
                            padding: EdgeInsets.symmetric(vertical: 10)
                                .copyWith(left: 20, right: 20),
                            prefix: Text("JS手动解析"),
                            child: Icon(CupertinoIcons.right_chevron, size: 15),
                          ),
                        ),
                      ],
                    ),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text('测试'),
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            await showCupertinoModalBottomSheet(
                              // useRootNavigator: true,
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => DebugRuleNew(
                                  type: 1,
                                  rule: widget.rule,
                                  debugRuleResult: widget.debugRuleResult),
                            );

                            print(widget.debugRuleResult['chapterList']);
                          },
                          child: CupertinoFormRow(
                            padding: EdgeInsets.symmetric(vertical: 10)
                                .copyWith(left: 20, right: 20),
                            prefix: Text("测试请求"),
                            child: Icon(CupertinoIcons.right_chevron, size: 15),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class EditRuleDiscover extends StatefulWidget {
  final Rule rule;
  final Map<String, SearchLists> debugRuleResult;
  const EditRuleDiscover(
      {@required this.rule, @required this.debugRuleResult, Key key})
      : super(key: key);

  @override
  State<EditRuleDiscover> createState() => _EditRuleDiscoverState();
}

class _EditRuleDiscoverState extends State<EditRuleDiscover> {
  final _textEditingController = TextEditingController();

  Widget _buildFromRow(BuildContext context2,
      {String name,
      String prefix,
      RuleRowType ruleRowType,
      void Function() onComplete,
      bool indent = false}) {
    final child = InkWell(
        onTap: () async {
          _textEditingController.text = Utils.empty(name) ? '' : name;
          Navigator.of(context2)
              .push(CupertinoPageRoute(
                  builder: (context) => EditRuleInput(
                        ruleRowType: ruleRowType,
                        textEditingController: _textEditingController,
                        // isBottomSheet: true,
                      )))
              .whenComplete(() => setState(() => onComplete()));
        },
        child: CupertinoFormRow(
          padding: indent
              ? null
              : EdgeInsets.symmetric(vertical: 10)
                  .copyWith(left: 20, right: 10),
          prefix: Text(prefix),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                Utils.empty(name) ? '' : name,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: CupertinoTheme.of(context).textTheme.textStyle,
                // style: TextStyle(fontSize: 14),
              )),
              SizedBox(width: 5),
              Icon(CupertinoIcons.right_chevron, size: 15),
              SizedBox(width: 5)
            ],
          ),
        ));

    return indent ? CupertinoFormRow(child: child) : child;
  }

  @override
  Widget build(BuildContext context) {
    final editSourceProvider =
        Provider.of<EditSourceProvider>(context, listen: false);
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          // previousPageTitle: "更多配置",
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text("保存"),
            onPressed: () {
              Utils.toast("开始保存");
              editSourceProvider
                  .handleSelect([widget.rule], MenuEditSource.save);
            },
          ),
          middle: Text("发现规则"),
          border: null,
        ),
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                  CupertinoFormSection(
                    headerPadding: EdgeInsetsDirectional.zero,
                    header: Text("请求地址规则"),
                    children: [
                      _buildFromRow(
                        context,
                        ruleRowType: RuleRowType.discoverUrl,
                        prefix: "地址(discoverUrl)",
                        name: widget.rule.discoverUrl,
                        onComplete: () => widget.rule.discoverUrl =
                            _textEditingController.text,
                      ),
                    ],
                  ),
                  CupertinoFormSection(
                    headerPadding: EdgeInsetsDirectional.zero,
                    header: Text("发现响应规则"),
                    children: [
                      _buildFromRow(
                        context,
                        ruleRowType: RuleRowType.MoreKeys,
                        prefix: "更多键(moreKeys)",
                        name: widget.rule.discoverMoreKeys,
                        onComplete: () => widget.rule.discoverMoreKeys =
                            _textEditingController.text,
                      ),
                      _buildFromRow(
                        context,
                        ruleRowType: RuleRowType.discoverList,
                        prefix: "列表(discoverList)",
                        name: widget.rule.discoverList,
                        onComplete: () => widget.rule.discoverList =
                            _textEditingController.text,
                      ),
                      _buildFromRow(
                        context,
                        indent: true,
                        ruleRowType: RuleRowType.discoverNextUrl,
                        prefix: "下一页(nextPageUrl)",
                        name: widget.rule.discoverNextUrl,
                        onComplete: () => widget.rule.discoverNextUrl =
                            _textEditingController.text,
                      ),
                      _buildFromRow(
                        context,
                        indent: true,
                        ruleRowType: RuleRowType.discoverName,
                        prefix: "名称(name)",
                        name: widget.rule.discoverName,
                        onComplete: () => widget.rule.discoverName =
                            _textEditingController.text,
                      ),
                      _buildFromRow(
                        context,
                        indent: true,
                        ruleRowType: RuleRowType.discoverAuthor,
                        prefix: "作者(author)",
                        name: widget.rule.discoverAuthor,
                        onComplete: () => widget.rule.discoverAuthor =
                            _textEditingController.text,
                      ),
                      _buildFromRow(
                        context,
                        indent: true,
                        ruleRowType: RuleRowType.discoverCover,
                        prefix: "封面(cover)",
                        name: widget.rule.discoverCover,
                        onComplete: () => widget.rule.discoverCover =
                            _textEditingController.text,
                      ),
                      _buildFromRow(
                        context,
                        indent: true,
                        ruleRowType: RuleRowType.discoverChapter,
                        prefix: "最新章节(lastChapter)",
                        name: widget.rule.discoverChapter,
                        onComplete: () => widget.rule.discoverChapter =
                            _textEditingController.text,
                      ),
                      _buildFromRow(
                        context,
                        indent: true,
                        ruleRowType: RuleRowType.searchTags,
                        prefix: "标签(tags)",
                        name: widget.rule.discoverTags,
                        onComplete: () => widget.rule.discoverTags =
                            _textEditingController.text,
                      ),
                      _buildFromRow(
                        context,
                        indent: true,
                        ruleRowType: RuleRowType.searchDescription,
                        prefix: "简介(desc)",
                        name: widget.rule.discoverDescription,
                        onComplete: () => widget.rule.discoverDescription =
                            _textEditingController.text,
                      ),
                      _buildFromRow(
                        context,
                        indent: true,
                        ruleRowType: RuleRowType.discoverResultUrl,
                        prefix: "结果地址(resultUrl)",
                        name: widget.rule.discoverResult,
                        onComplete: () => widget.rule.discoverResult =
                            _textEditingController.text,
                      ),
                    ],
                  ),
                  CupertinoFormSection(
                    headerPadding: EdgeInsetsDirectional.zero,
                    header: Text('手动解析'),
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => Utils.toast('没写,下版本完善'),
                        child: CupertinoFormRow(
                          padding: EdgeInsets.symmetric(vertical: 10)
                              .copyWith(left: 20, right: 20),
                          prefix: Text("JS手动解析"),
                          child: Icon(CupertinoIcons.right_chevron, size: 15),
                        ),
                      ),
                    ],
                  ),
                  CupertinoFormSection(
                    headerPadding: EdgeInsetsDirectional.zero,
                    header: Text('测试'),
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          await showCupertinoModalBottomSheet(
                            // useRootNavigator: true,
                            expand: true,
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => DebugRuleNew(
                                type: 0,
                                rule: widget.rule,
                                debugRuleResult: widget.debugRuleResult),
                          );

                          print(widget.debugRuleResult['searchList']);
                        },
                        child: CupertinoFormRow(
                          padding: EdgeInsets.symmetric(vertical: 10)
                              .copyWith(left: 20, right: 20),
                          prefix: Text("测试请求"),
                          child: Icon(CupertinoIcons.right_chevron, size: 15),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditRuleChapter extends StatefulWidget {
  final Rule rule;
  final Map<String, SearchLists> debugRuleResult;
  const EditRuleChapter({this.rule, this.debugRuleResult, Key key})
      : super(key: key);

  @override
  State<EditRuleChapter> createState() => _EditRuleChapterState();
}

class _EditRuleChapterState extends State<EditRuleChapter> {
  final _textEditingController = TextEditingController();

  Widget _buildFromRow(BuildContext context2,
      {String name,
      String prefix,
      RuleRowType ruleRowType,
      void Function() onComplete,
      bool indent = false}) {
    assert(ruleRowType != null);

    final child = InkWell(
        onTap: () async {
          _textEditingController.text = Utils.empty(name) ? '' : name;
          Navigator.of(context2)
              .push(CupertinoPageRoute(
                  builder: (context) => EditRuleInput(
                        ruleRowType: ruleRowType,
                        textEditingController: _textEditingController,
                        // isBottomSheet: true,
                      )))
              .whenComplete(() => setState(() => onComplete()));
        },
        child: CupertinoFormRow(
          padding: indent
              ? null
              : EdgeInsets.symmetric(vertical: 10)
                  .copyWith(left: 20, right: 10),
          prefix: Text(prefix ?? getEditRuleTypeName(ruleRowType)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                Utils.empty(name) ? '' : name,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: CupertinoTheme.of(context).textTheme.textStyle,
              )),
              SizedBox(width: 5),
              Icon(CupertinoIcons.right_chevron, size: 15),
              SizedBox(width: 5)
            ],
          ),
        ));

    return indent ? CupertinoFormRow(child: child) : child;
  }

  @override
  Widget build(BuildContext context) {
    final editSourceProvider =
        Provider.of<EditSourceProvider>(context, listen: false);
    return Material(
      child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            // previousPageTitle: "更多配置",
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text("保存"),
              onPressed: () {
                Utils.toast("开始保存");
                editSourceProvider
                    .handleSelect([widget.rule], MenuEditSource.save);
              },
            ),
            middle: Text("章节规则"),
            border: null,
          ),
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text("请求地址规则"),
                      children: [
                        _buildFromRow(
                          context,
                          ruleRowType: RuleRowType.chapterUrl,
                          name: widget.rule.chapterUrl,
                          onComplete: () => widget.rule.chapterUrl =
                              _textEditingController.text,
                        ),
                      ],
                    ),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text("章节响应规则"),
                      children: [
                        CupertinoFormRow(
                            prefix: Text("启用多线路"),
                            child: CupertinoSwitch(
                                value: widget.rule.enableMultiRoads,
                                onChanged: (value) => setState(() =>
                                    widget.rule.enableMultiRoads = value))),
                        _buildFromRow(
                          context,
                          ruleRowType: RuleRowType.chapterRoads,
                          name: widget.rule.chapterRoads,
                          onComplete: () => widget.rule.chapterRoads =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.chapterRoadName,
                          name: widget.rule.chapterRoadName,
                          onComplete: () => widget.rule.chapterRoadName =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          ruleRowType: RuleRowType.chapterList,
                          name: widget.rule.chapterList,
                          onComplete: () => widget.rule.chapterList =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.chapterNextUrl,
                          name: widget.rule.chapterNextUrl,
                          onComplete: () => widget.rule.chapterNextUrl =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.chapterName,
                          name: widget.rule.chapterName,
                          onComplete: () => widget.rule.chapterName =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.chapterTime,
                          name: widget.rule.chapterTime,
                          onComplete: () => widget.rule.chapterTime =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.chapterCover,
                          name: widget.rule.chapterCover,
                          onComplete: () => widget.rule.chapterCover =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.chapterLock,
                          name: widget.rule.chapterLock,
                          onComplete: () => widget.rule.chapterLock =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          indent: true,
                          ruleRowType: RuleRowType.chapterResult,
                          name: widget.rule.chapterResult,
                          onComplete: () => widget.rule.chapterResult =
                              _textEditingController.text,
                        ),
                      ],
                    ),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text('手动解析'),
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => Utils.toast('没写,下版本完善'),
                          child: CupertinoFormRow(
                            padding: EdgeInsets.symmetric(vertical: 10)
                                .copyWith(left: 20, right: 20),
                            prefix: Text("JS手动解析"),
                            child: Icon(CupertinoIcons.right_chevron, size: 15),
                          ),
                        ),
                      ],
                    ),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text('测试'),
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            await showCupertinoModalBottomSheet(
                              // useRootNavigator: true,
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => DebugRuleNew(
                                  type: 2,
                                  rule: widget.rule,
                                  debugRuleResult: widget.debugRuleResult),
                            );

                            print(widget.debugRuleResult['chapterList']);
                          },
                          child: CupertinoFormRow(
                            padding: EdgeInsets.symmetric(vertical: 10)
                                .copyWith(left: 20, right: 20),
                            prefix: Text("测试请求"),
                            child: Icon(CupertinoIcons.right_chevron, size: 15),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class EditRuleContent extends StatefulWidget {
  final Rule rule;
  final Map<String, SearchLists> debugRuleResult;
  const EditRuleContent({this.rule, this.debugRuleResult, Key key})
      : super(key: key);

  @override
  State<EditRuleContent> createState() => _EditRuleContentState();
}

class _EditRuleContentState extends State<EditRuleContent> {
  final _textEditingController = TextEditingController();

  Widget _buildFromRow(BuildContext context2,
      {String name,
      String prefix,
      RuleRowType ruleRowType,
      void Function() onComplete,
      bool indent = false}) {
    assert(ruleRowType != null);

    final child = InkWell(
        onTap: () async {
          _textEditingController.text = Utils.empty(name) ? '' : name;
          Navigator.of(context2)
              .push(CupertinoPageRoute(
                  builder: (context) => EditRuleInput(
                        ruleRowType: ruleRowType,
                        textEditingController: _textEditingController,
                        // isBottomSheet: true,
                      )))
              .whenComplete(() => setState(() => onComplete()));
        },
        child: CupertinoFormRow(
          padding: indent
              ? null
              : EdgeInsets.symmetric(vertical: 10)
                  .copyWith(left: 20, right: 10),
          prefix: Text(prefix ?? getEditRuleTypeName(ruleRowType)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                Utils.empty(name) ? '' : name,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: CupertinoTheme.of(context).textTheme.textStyle,
              )),
              SizedBox(width: 5),
              Icon(CupertinoIcons.right_chevron, size: 15),
              SizedBox(width: 5)
            ],
          ),
        ));

    return indent ? CupertinoFormRow(child: child) : child;
  }

  @override
  Widget build(BuildContext context) {
    final editSourceProvider =
        Provider.of<EditSourceProvider>(context, listen: false);
    return Material(
      child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            // previousPageTitle: "更多配置",
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text("保存"),
              onPressed: () {
                Utils.toast("开始保存");
                editSourceProvider
                    .handleSelect([widget.rule], MenuEditSource.save);
              },
            ),
            middle: Text("正文规则"),
            border: null,
          ),
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text("请求地址规则"),
                      children: [
                        _buildFromRow(
                          context,
                          ruleRowType: RuleRowType.contentUrl,
                          name: widget.rule.contentUrl,
                          onComplete: () => widget.rule.contentUrl =
                              _textEditingController.text,
                        ),
                      ],
                    ),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text("正文响应"),
                      children: [
                        _buildFromRow(
                          context,
                          ruleRowType: RuleRowType.contentItems,
                          name: widget.rule.contentItems,
                          onComplete: () => widget.rule.contentItems =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          ruleRowType: RuleRowType.contentNextUrl,
                          name: widget.rule.contentNextUrl,
                          onComplete: () => widget.rule.contentNextUrl =
                              _textEditingController.text,
                        ),
                        _buildFromRow(
                          context,
                          ruleRowType: RuleRowType.contentDecrypt,
                          name: widget.rule.contentDecrypt,
                          onComplete: () => widget.rule.contentDecrypt =
                              _textEditingController.text,
                        ),
                      ],
                    ),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text('手动解析'),
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => Utils.toast('没写,下版本完善'),
                          child: CupertinoFormRow(
                            padding: EdgeInsets.symmetric(vertical: 10)
                                .copyWith(left: 20, right: 20),
                            prefix: Text("JS手动解析"),
                            child: Icon(CupertinoIcons.right_chevron, size: 15),
                          ),
                        ),
                      ],
                    ),
                    CupertinoFormSection(
                      headerPadding: EdgeInsetsDirectional.zero,
                      header: Text('测试'),
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            await showCupertinoModalBottomSheet(
                              // useRootNavigator: true,
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => DebugRuleNew(
                                  type: 3,
                                  rule: widget.rule,
                                  debugRuleResult: widget.debugRuleResult),
                            );
                          },
                          child: CupertinoFormRow(
                            padding: EdgeInsets.symmetric(vertical: 10)
                                .copyWith(left: 20, right: 20),
                            prefix: Text("测试请求"),
                            child: Icon(CupertinoIcons.right_chevron, size: 15),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class EditRulePage extends StatefulWidget {
  final Rule rule;
  final EditSourceProvider provider;
  const EditRulePage({
    this.rule,
    @required this.provider,
    Key key,
  }) : super(key: key);
  @override
  _EditRulePageState createState() => _EditRulePageState();
}

class _EditRulePageState extends State<EditRulePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  var isLoading = false;
  Color primaryColor;
  Rule rule;
  FocusNode codeFocusNode;
  // TextEditingController
  final Map<String, SearchLists> debugRuleResult = {};
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
          )).whenComplete(() => this.setState(() {}));
    }
  }

  @override
  void initState() {
    super.initState();
    rule = widget.rule == null ? Rule.newRule() : widget.rule.copyWith();
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  final _textEditingController = TextEditingController();

  void onChangeContent(
      {RuleRowType rowType, String rowName, void Function() onComplete}) async {
    _textEditingController.text = rowName;
    Navigator.of(context).push(MaterialWithModalsPageRoute(
      builder: (context) {
        switch (rowType) {
          case RuleRowType.commonSearch:
            return EditRuleSearch(rule: rule, debugRuleResult: debugRuleResult);
            break;
          case RuleRowType.commonDiscover:
            return EditRuleDiscover(
                rule: rule, debugRuleResult: debugRuleResult);
            break;
          case RuleRowType.commonChapter:
            return EditRuleChapter(
                rule: rule, debugRuleResult: debugRuleResult);
            break;
          case RuleRowType.commonContent:
            return EditRuleContent(
                rule: rule, debugRuleResult: debugRuleResult);
            break;

          default:
            return EditRuleInput(
              textEditingController: _textEditingController,
              ruleRowType: rowType,
            );
            break;
        }
      },
    )).whenComplete(() => setState(() => onComplete()));
  }

  Widget _buildCupertinoFormRowWithHome(RuleRowType ruleRowType,
      {String prefix, String name}) {
    final onChange = (RuleRowType type) async {
      switch (type) {
        case RuleRowType.debugRule:
          invokeTap(DebugRulePage(rule: rule));
          break;

        case RuleRowType.basicMore:
          showCupertinoModalBottomSheet(
            // useRootNavigator: true,
            expand: true,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => EditRuleWithMoreConfig(
              rule: rule,
            ),
          );
          break;
        case RuleRowType.basicType:
          showCupertinoModalPopup(
            context: context,
            builder: (_) => CupertinoActionSheet(
              actions: List.generate(
                5,
                (index) {
                  final typeName = API.getRuleContentTypeName(index);
                  return CupertinoActionSheetAction(
                    child: Text(
                      "${typeName}",
                      style: TextStyle(
                        color: rule.contentType == index ? Colors.red : null,
                        // fontWeight: FontWeight.bold,
                        // fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      rule.contentType = index;
                      setState(() {});
                      Navigator.pop(_);
                      //provider.changeSpeed(quality);
                    },
                  );
                },
              ),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(_),
                child: Text("返回"),
                isDestructiveAction: true,
              ),
            ),
          );
          break;
        case RuleRowType.basicName:
          await onChangeContent(
              rowType: type,
              rowName: rule.name,
              onComplete: () =>
                  setState(() => rule.name = _textEditingController.text));
          break;
        case RuleRowType.basicHost:
          await onChangeContent(
              rowType: type,
              rowName: rule.host,
              onComplete: () =>
                  setState(() => rule.host = _textEditingController.text));
          break;
        case RuleRowType.basicAuthor:
          await onChangeContent(
              rowType: type,
              rowName: rule.author,
              onComplete: () =>
                  setState(() => rule.author = _textEditingController.text));
          break;
        case RuleRowType.commonSearch:
          await onChangeContent(
              rowType: type,
              rowName: "搜索规则",
              onComplete: () => setState(() => null));
          break;
        case RuleRowType.commonDiscover:
          await onChangeContent(
              rowType: type,
              rowName: "发现规则",
              onComplete: () => setState(() => null));
          break;
        case RuleRowType.commonChapter:
          await onChangeContent(
              rowType: type,
              rowName: "章节规则",
              onComplete: () => setState(() => null));
          break;
        case RuleRowType.commonContent:
          await onChangeContent(
              rowType: type,
              rowName: "正文规则",
              onComplete: () => setState(() => null));
          break;

        default:
      }
    };

    return InkWell(
      onTap: () {
        onChange(ruleRowType);
      },
      child: SizedBox(
        child: CupertinoFormRow(
          padding:
              EdgeInsets.symmetric(vertical: 10).copyWith(left: 20, right: 10),
          prefix: Text(
            prefix,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          // padding: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                Utils.empty(name) ? '' : name,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: CupertinoTheme.of(context).textTheme.textStyle,
              )),
              SizedBox(width: 5),
              Icon(CupertinoIcons.right_chevron, size: 15),
              SizedBox(width: 5)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return CupertinoFormSection(
      headerPadding: EdgeInsetsDirectional.zero,
      header: Text('基本信息'),
      children: [
        _buildCupertinoFormRowWithHome(RuleRowType.basicName,
            prefix: "名称", name: rule.name),
        _buildCupertinoFormRowWithHome(RuleRowType.basicHost,
            prefix: "域名", name: rule.host),
        _buildCupertinoFormRowWithHome(RuleRowType.basicAuthor,
            prefix: "作者", name: rule.author),
        _buildCupertinoFormRowWithHome(RuleRowType.basicType,
            prefix: "类型", name: rule.ruleTypeName),
        _buildCupertinoFormRowWithHome(RuleRowType.basicMore, prefix: "更多配置"),
      ],
    );
  }

  Widget _buildNormalConfig() {
    return CupertinoFormSection(
      headerPadding: EdgeInsetsDirectional.zero,
      header: Text('常用配置'),
      children: [
        _buildCupertinoFormRowWithHome(RuleRowType.commonSearch,
            prefix: "搜索规则",
            name: Utils.empty(rule.searchUrl) && Utils.empty(rule.searchList)
                ? "未配置"
                : "已配置"),
        _buildCupertinoFormRowWithHome(RuleRowType.commonDiscover,
            prefix: "发现规则",
            name:
                Utils.empty(rule.discoverUrl) && Utils.empty(rule.discoverList)
                    ? "未配置"
                    : "已配置"),
        _buildCupertinoFormRowWithHome(RuleRowType.commonChapter,
            prefix: "章节规则",
            name: Utils.empty(rule.chapterUrl) && Utils.empty(rule.chapterList)
                ? "未配置"
                : "已配置"),
        _buildCupertinoFormRowWithHome(RuleRowType.commonContent,
            prefix: "正文规则",
            name: Utils.empty(rule.contentUrl) && Utils.empty(rule.contentItems)
                ? "未配置"
                : "已配置"),
      ],
    );
  }

  Widget _buildDebugRule() {
    return CupertinoFormSection(
      headerPadding: EdgeInsetsDirectional.zero,
      header: Text('调试'),
      children: [
        _buildCupertinoFormRowWithHome(RuleRowType.debugRule, prefix: "调试规则"),
      ],
    );
  }

  Widget _buildPage(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          // transitionBetweenRoutes: false,
          border: null,
          middle: Text(
            widget.rule == null ? '新建规则' : widget.rule.name,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            maxLines: 1,
          ),
          // trailing: CupertinoButton(
          //   alignment: Alignment.center,
          //   padding: EdgeInsets.zero,
          //   child: Text("保存"),
          //   onPressed: () {
          //     _saveRule(context);
          //   },
          // ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                alignment: Alignment.center,
                padding: EdgeInsets.zero,
                child: Text("保存"),
                onPressed: () {
                  _saveRule(context);
                },
              ),
              _buildpopupMenu(context),

              // CupertinoButton(
              //   alignment: Alignment.center,
              //   padding: EdgeInsets.zero,
              //   child: Text("更多"),
              //   onPressed: () {},
              // )
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    CustomScrollView(slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            _buildBasicInfo(),
                            _buildNormalConfig(),
                            _buildDebugRule(),
                          ],
                        ),
                      ),
                    ]),
                    JsDebug(rule: rule),
                    // Positioned(
                    //   top: null,
                    //   right: 0,
                    //   bottom: 10,
                    //   child: JsDebug(rule: rule),
                    // ),
                  ],
                ),
              ),
              // ...inputList.map((list) => _buildInputHelp(list)).toList(),
              // ...inputList.map((list) => _buildInputHelp(list)).toList(),
            ],
          ),
        ),
      ),
    );

    // return Scaffold(
    //   appBar: PreferredSize(
    //     preferredSize: Size.fromHeight(80.0),
    //     child: AppBar(
    //       titleSpacing: 0,
    //       title: Text(widget.rule == null ? '新建规则' : '编辑规则'),
    //       actions: [
    //         IconButton(
    //           icon: Icon(FIcons.share_2),
    //           tooltip: "分享",
    //           onPressed: () {
    //             Share.share(RuleCompress.compass(rule));
    //             // FlutterShare.share(
    //             //   title: '亦搜 eso',
    //             //   text: RuleCompress.compass(rule), //jsonEncode(rule.toJson()),
    //             //   //linkUrl: '${searchItem.url}',
    //             //   chooserTitle: '选择分享的应用',
    //             // );
    //           },
    //         ),
    //         IconButton(
    //           icon: Icon(FIcons.save),
    //           iconSize: 21,
    //           tooltip: "保存",
    //           onPressed: () => _saveRule(context),
    //         ),
    //         IconButton(
    //           icon: Icon(Icons.bug_report),
    //           tooltip: "调试",
    //           onPressed: () async {
    //             if (isLoading) return;
    //             isLoading = true;
    //             rule.modifiedTime = DateTime.now().microsecondsSinceEpoch;
    //             await Global.ruleDao.insertOrUpdateRule(rule);
    //             isLoading = false;
    //             // Navigator.of(context).push(
    //             //     MaterialPageRoute(builder: (context) => DebugRulePage(rule: rule)));

    //             invokeTap(DebugRulePage(rule: rule));
    //           },
    //         ),
    //         _buildpopupMenu(context),
    //       ],
    //     ),
    //   ),
    //   body: Column(
    //     children: <Widget>[
    //       Expanded(
    //         child: Stack(
    //           children: [
    //             editView,
    //             Positioned(
    //               top: isNotCollapsed ? 1 : null,
    //               right: 0,
    //               bottom: 0,
    //               child: Container(
    //                 width: isNotCollapsed ? size.width - 10 : null,
    //                 constraints: isNotCollapsed
    //                     ? BoxConstraints(maxHeight: size.height - 150 - bottom)
    //                     : null,
    //                 child: Card(
    //                   child: isNotCollapsed
    //                       ? Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             Expanded(
    //                               flex: 2,
    //                               child: HighLightCodeEditor(
    //                                 codeKey,
    //                                 code,
    //                                 focusNode: codeFocusNode,
    //                               ),
    //                             ),
    //                             Expanded(
    //                               flex: 1,
    //                               child: SingleChildScrollView(
    //                                   child: SelectableText(s)),
    //                             ),
    //                             Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.spaceBetween,
    //                               children: [
    //                                 InkWell(
    //                                   onTap: () async {
    //                                     await Clipboard.setData(
    //                                         ClipboardData(text: s));
    //                                     Utils.toast("已复制结果");
    //                                   },
    //                                   child: Padding(
    //                                     padding: const EdgeInsets.all(8.0),
    //                                     child: Text("复制结果"),
    //                                   ),
    //                                 ),
    //                                 InkWell(
    //                                   onTap: () async {
    //                                     await Clipboard.setData(ClipboardData(
    //                                         text: codeKey.currentState?.code ??
    //                                             code));
    //                                     Utils.toast("已复制代码");
    //                                   },
    //                                   child: Padding(
    //                                     padding: const EdgeInsets.all(8.0),
    //                                     child: Text("复制代码"),
    //                                   ),
    //                                 ),
    //                                 InkWell(
    //                                   onTap: () =>
    //                                       codeKey.currentState?.format(),
    //                                   child: Padding(
    //                                     padding: const EdgeInsets.all(8.0),
    //                                     child: Text("格式化"),
    //                                   ),
    //                                 ),
    //                                 InkWell(
    //                                   onTap: () async {
    //                                     try {
    //                                       await JSEngine.setEnvironment(
    //                                           1, rule, "", rule.host, "", "");
    //                                       final x = await JSEngine.evaluate(
    //                                           codeKey.currentState?.code ??
    //                                               code);
    //                                       setState(() {
    //                                         s = "$x";
    //                                       });
    //                                     } catch (e, st) {
    //                                       setState(() {
    //                                         s = "$e\n$st";
    //                                       });
    //                                     }
    //                                   },
    //                                   child: Padding(
    //                                     padding: const EdgeInsets.all(8.0),
    //                                     child: Text("运行"),
    //                                   ),
    //                                 ),
    //                                 InkWell(
    //                                   onTap: () {
    //                                     code =
    //                                         codeKey.currentState?.code ?? code;
    //                                     setState(() =>
    //                                         isNotCollapsed = !isNotCollapsed);
    //                                   },
    //                                   child: Padding(
    //                                     padding: const EdgeInsets.all(8.0),
    //                                     child: Text("折叠"),
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ],
    //                         )
    //                       : InkWell(
    //                           onTap: () {
    //                             code = codeKey.currentState?.code ?? code;
    //                             setState(
    //                                 () => isNotCollapsed = !isNotCollapsed);
    //                           },
    //                           child: Padding(
    //                             padding: const EdgeInsets.symmetric(
    //                                 horizontal: 10, vertical: 4),
    //                             child: Text("JS测试"),
    //                           ),
    //                         ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //       ...inputList.map((list) => _buildInputHelp(list)).toList(),
    //       // SizedBox(
    //       //   height: 50,
    //       // )
    //     ],
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;

    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        isLargeScreen = true;
      } else {
        isLargeScreen = false;
      }

      return Row(children: <Widget>[
        Expanded(
          child: _buildPage(context),
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

  Widget _buildInputHelp(Map<String, String> inputList) {
    final inputKeys = inputList.keys.toList();
    final inputValues = inputList.values.toList();
    return Container(
      height: 32,
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

  TextEditingController currentController;
  void Function(String text) currentOnChanged;

  Future<void> _saveRule(BuildContext context) async {
    Utils.toast("开始保存");
    // if (isLoading) return;
    // isLoading = true;
    widget.provider.handleSelect([rule], MenuEditSource.save);

    // final count = await Global.ruleDao.insertOrUpdateRule(rule);
    // isLoading = false;
    // if (count > 0) {
    //   Utils.toast("保存成功");
    //   return true;
    // } else {
    //   Utils.toast("保存失败");
    //   return false;
    // }
  }

  Future<bool> _loadFromClipBoard(BuildContext context, bool isYICIYUAN) async {
    if (isLoading) return false;
    isLoading = true;
    final text = (await Clipboard.getData(Clipboard.kTextPlain)).text;
    isLoading = false;
    try {
      rule = isYICIYUAN
          ? Rule.fromYiCiYuan(jsonDecode(text), rule)
          : text.startsWith(RuleCompress.tag)
              ? RuleCompress.decompass(text, rule)
              : Rule.fromJson(jsonDecode(text), rule);
      setState(() {});
      Utils.toast("已从剪贴板导入");
      return true;
    } catch (e) {
      Utils.toast("导入失败：" + e.toString(), duration: Duration(seconds: 2));
      return false;
    }
  }

  Widget _buildpopupMenu(BuildContext context) {
    return PullDownButton(
      position: PullDownMenuPosition.under,
      widthConfiguration: PullDownMenuWidthConfiguration(200),
      buttonBuilder: (BuildContext context, showMenu) => CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: showMenu,
        // padding: EdgeInsets.zero,
        child: const Text("更多"),
      ),
      itemBuilder: (BuildContext context) {
        final onSelected = (int type) {
          switch (type) {
            case 0:
              invokeTap(Platform.isWindows
                  ? LoginRulePageWithWindows(rule: rule)
                  : LoginRulePage(rule: rule));

              break;
            case 1:
              _loadFromClipBoard(context, false);
              break;
            case 2:
              _loadFromClipBoard(context, true);
              break;

            case 3:
              Clipboard.setData(
                  ClipboardData(text: RuleCompress.compass(rule)));
              Utils.toast("已保存到剪贴板");
              break;

            case 4:
              Clipboard.setData(
                  ClipboardData(text: jsonEncode(rule.toJson(true))));
              Utils.toast("已保存到剪贴板");
              break;

            case 5:
              Share.share(jsonEncode(rule.toJson(true)));
              break;
            case 6:
              invokeTap(DiscoverFuture(rule: rule));
              break;
            case 7:
              launch(
                  'https://github.com/mabDc/eso_source/blob/master/README.md');
              break;
            case 8:
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text('警告(不可恢复)'),
                    content: Text("确定要删除 ${rule.name}吗?"),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      CupertinoDialogAction(
                        child: Text('确定'),
                        onPressed: () {
                          Global.ruleDao.deleteRule(rule);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
              break;

            default:
              break;
          }
        };

        return [
          // const PullDownMenuTitle(title: Text('规则',style: TextStyle(fontSize: ),)),
          // const PullDownMenuDivider(),

          SelectablePullDownMenuItem(
            title: '登陆',
            selected: false,
            onTap: () => onSelected(0),
            icon: CupertinoIcons.person,
          ),
          const PullDownMenuDivider(),
          SelectablePullDownMenuItem(
            title: '从剪贴板导入',
            selected: false,
            onTap: () => onSelected(1),
            icon: CupertinoIcons.pencil_outline,
          ),
          const PullDownMenuDivider(),
          SelectablePullDownMenuItem(
            title: '阅读或异次元',
            selected: false,
            onTap: () => onSelected(2),
            icon: CupertinoIcons.book,
          ),
          const PullDownMenuDivider(),
          SelectablePullDownMenuItem(
            title: '导出到剪贴板',
            selected: false,
            onTap: () => onSelected(3),
            icon: CupertinoIcons.plus_square_fill_on_square_fill,
          ),
          const PullDownMenuDivider(),
          SelectablePullDownMenuItem(
            title: '复制原始文本',
            selected: false,
            onTap: () => onSelected(4),
            icon: CupertinoIcons.square_on_square,
          ),
          const PullDownMenuDivider(),
          SelectablePullDownMenuItem(
            title: '分享原始文本',
            selected: false,
            onTap: () => onSelected(5),
            icon: CupertinoIcons.arrowshape_turn_up_right_circle,
            // textStyle: _themn.textStyle.copyWith(color: Colors.red),
          ),
          const PullDownMenuDivider(),
          SelectablePullDownMenuItem(
            title: '预览',
            selected: false,
            onTap: () => onSelected(6),
            icon: CupertinoIcons.cube,
            // textStyle: _themn.textStyle.copyWith(color: Colors.red),
          ),
          const PullDownMenuDivider(),
          SelectablePullDownMenuItem(
            title: '帮助',
            selected: false,
            onTap: () => onSelected(7),
            icon: CupertinoIcons.question_circle,
            // textStyle: _themn.textStyle.copyWith(color: Colors.red),
          ),
          const PullDownMenuDivider.large(),
          SelectablePullDownMenuItem(
            title: '删除',
            selected: false,
            onTap: () => onSelected(8),
            icon: CupertinoIcons.delete,
            iconColor: Colors.red,
            // textStyle: _themn.textStyle.copyWith(color: Colors.red),
          ),
        ];
      },
    );
  }
}
