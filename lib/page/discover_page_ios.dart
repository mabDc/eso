import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

// import 'package:cupertino_lists/cupertino_lists.dart';
import 'package:eso/api/api.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/rule_dao.dart';
import 'package:eso/global.dart';
import 'package:eso/menu/menu_discover_source.dart';
import 'package:eso/menu/menu_edit_source.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/page/discover_page.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/page/source/edit_rule_page.dart';
import 'package:eso/page/source/edit_source_page.dart';
import 'package:eso/page/source/editor/highlight_code_editor_theme.dart';
import 'package:eso/ui/ui_add_rule_dialog.dart';
import 'package:eso/ui/widgets/empty_list_msg_view.dart';
import 'package:eso/ui/widgets/keep_alive_widget.dart';
import 'package:eso/ui/widgets/keyboard_dismiss_behavior_view.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/rule_comparess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:left_scroll_actions/left_scroll_actions.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart';

class DiscoverPageWinthIOS extends StatefulWidget {
  const DiscoverPageWinthIOS({Key key}) : super(key: key);

  @override
  State<DiscoverPageWinthIOS> createState() => _DiscoverPageWinthIOSState();
}

class _DiscoverPageWinthIOSState extends State<DiscoverPageWinthIOS> {
  var isLargeScreen = false;

  Widget detailPage;
  TextEditingController _searchEdit = TextEditingController();
  FocusNode focusNode;

  void invokeTap(Widget detailPage) {
    if (isLargeScreen) {
      this.detailPage = detailPage;

      setState(() {});
    } else {
      Navigator.of(context).push(MaterialWithModalsPageRoute(
        builder: (_) => detailPage,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    // print("initState");
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    // print("发现页销毁");
    focusNode?.dispose();
    super.dispose();
  }

  final List<IconData> _icons = [
    Icons.image,
    CupertinoIcons.book_circle_fill,
    CupertinoIcons.play_circle_fill,
    CupertinoIcons.headphones,
    Icons.rss_feed_outlined
  ];
  final List<double> _iconsSize = [35, 32, 36, 28, 24, 24];

  Widget _buildListItemLeading(Rule rule) {
    // rule.icon = "https://manwa.me/favicon.ico";

    // print("rule.icon:${rule.icon}");

    final icon = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.1), width: 1),
      ),
      child: Center(
        child: Icon(
          _icons[rule.contentType],
          color: IconTheme.of(context).color,
          size: _iconsSize[rule.contentType],
        ),
      ),
    );

    return Utils.empty(rule.icon)
        ? icon
        : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
                imageUrl: rule.icon,
                fit: BoxFit.contain,
                placeholder: (context, url) => icon,
                errorWidget: (context, url, err) => icon),
          );
  }

  Widget _buildItems(BuildContext context, EditSourceProvider provider,
      List<Rule> rules, int index) {
    final rule =
        rules.where((element) => element.enableDiscover).elementAt(index);

// CupertinoListTile(title: title)
    // if (rule.icon.isNotEmpty) {
    //   print("${rule.name},${rule.icon}");
    // }

    return ListTile(
      dense: true,
      // contentPadding: EdgeInsets.zero,
      onTap: () {
        focusNode.unfocus();
        invokeTap(DiscoverFuture(rule: rule, key: Key(rule.id.toString())));
      },
      onLongPress: () => Navigator.of(context)
          .push(MaterialWithModalsPageRoute(
              builder: (context) =>
                  EditRulePage(rule: rule, provider: provider)))
          .whenComplete(() => provider.setShowGroup(null)),
      // leadingSize: 45,
      leading: Container(
        height: 50,
        width: 50,
        child: _buildListItemLeading(rule),
      ),
      // minVerticalPadding: 16,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text("${rule.name}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    textBaseline: TextBaseline.alphabetic,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  )

              // TextStyle(
              //     textBaseline: TextBaseline.alphabetic,
              //     fontSize: 14,
              //     height: 1,
              //     color: ),
              ),
          SizedBox(width: 5),
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
            alignment: Alignment.centerLeft,
            child: Text(
              '${rule.ruleTypeName}',
              style: TextStyle(
                fontSize: 10,
                height: 1.3,
                color: Colors.white,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
          ),
        ],
      ),
      // title: Container(
      //   width: 200,
      //   child: Row(
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     textBaseline: TextBaseline.alphabetic,
      //     children: <Widget>[
      //       Flexible(
      //         child: Padding(
      //           padding: const EdgeInsets.fromLTRB(0, 0, 0, 3),
      //           child: Text(
      //             rule.name,
      //             overflow: TextOverflow.ellipsis,
      //             maxLines: 1,
      //             style: TextStyle(
      //               textBaseline: TextBaseline.alphabetic,
      //               color: null,
      //               fontSize: 15,
      //               height: 1,
      //             ),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(width: 5),
      //       Container(
      //         height: 16,
      //         decoration: BoxDecoration(
      //           color: Theme.of(context).primaryColor,
      //           borderRadius: BorderRadius.circular(2),
      //         ),
      //         margin: const EdgeInsets.fromLTRB(0, 0, 0, 3),
      //         padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      //         alignment: Alignment.center,
      //         child: Text(
      //           '${rule.ruleTypeName}',
      //           style: TextStyle(
      //               fontSize: 10,
      //               height: 1.0,
      //               color: Theme.of(context).canvasColor,
      //               textBaseline: TextBaseline.alphabetic),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      subtitle: Text(
        rule.author == '' ? rule.host : '@${rule.author}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // style: TextStyle(
        //   fontSize: 12,
        // ),
      ),
      // trailing: (),
      trailing: PullDownButton(
        position: PullDownMenuPosition.under,
        widthConfiguration: PullDownMenuWidthConfiguration(150),
        buttonBuilder: (BuildContext context, showMenu) => CupertinoButton(
          // color: Colors.red,
          onPressed: () {
            focusNode.unfocus();
            showMenu();
          },
          // padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.ellipsis_vertical,
            // size: 30,
          ),
        ),
        itemBuilder: (BuildContext context) {
          final onSelected = (MenuDiscoverSource type) {
            switch (type) {
              case MenuDiscoverSource.edit:
                Navigator.of(context)
                    .push(MaterialWithModalsPageRoute(
                        builder: (context) =>
                            EditRulePage(rule: rule, provider: provider)))
                    .whenComplete(() => provider.setShowGroup(null));

                break;
              case MenuDiscoverSource.top:
                provider.handleSelect([rule], MenuEditSource.top);
                break;
              case MenuDiscoverSource.down:
                provider.handleSelect([rule], MenuEditSource.down);
                break;
              case MenuDiscoverSource.fuben:
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: Text('创建配置'),
                      content: Text("以配置 \"${rule.name}\"为蓝本，创建新的配置?"),
                      actions: [
                        CupertinoDialogAction(
                          child: Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        CupertinoDialogAction(
                          child: Text('创建'),
                          onPressed: () {
                            provider.handleSelect([rule], MenuEditSource.fuben);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                break;
              case MenuDiscoverSource.copy:
                Clipboard.setData(
                    ClipboardData(text: jsonEncode(rule.toJson(true))));
                Utils.toast("已复制 ${rule.name}");
                break;
              case MenuDiscoverSource.share:
                Share.share(RuleCompress.compass(rule));
                break;
              case MenuDiscoverSource.delete:
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
                            provider.handleSelect(
                                [rule], MenuEditSource.delete_this);
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
              title: '编辑规则',
              selected: true,
              onTap: () => onSelected(MenuDiscoverSource.edit),
              checkmark: CupertinoIcons.chevron_left_slash_chevron_right,
            ),
            const PullDownMenuDivider(),
            SelectablePullDownMenuItem(
              title: '置顶规则',
              selected: true,
              onTap: () => onSelected(MenuDiscoverSource.top),
              checkmark: CupertinoIcons.sort_up,
            ),
            const PullDownMenuDivider(),
            SelectablePullDownMenuItem(
              title: '取消置顶',
              selected: true,
              onTap: () => onSelected(MenuDiscoverSource.down),
              checkmark: CupertinoIcons.sort_down,
            ),
            const PullDownMenuDivider(),
            SelectablePullDownMenuItem(
              title: '创建副本',
              selected: true,
              onTap: () => onSelected(MenuDiscoverSource.fuben),
              checkmark: CupertinoIcons.plus_square_fill_on_square_fill,
            ),
            const PullDownMenuDivider(),
            SelectablePullDownMenuItem(
              title: '复制规则',
              selected: true,
              onTap: () => onSelected(MenuDiscoverSource.copy),
              checkmark: CupertinoIcons.square_on_square,
            ),
            const PullDownMenuDivider(),
            SelectablePullDownMenuItem(
              title: '分享规则',
              selected: true,
              onTap: () => onSelected(MenuDiscoverSource.share),
              checkmark: CupertinoIcons.arrowshape_turn_up_right_circle,
            ),
            const PullDownMenuDivider.large(),
            SelectablePullDownMenuItem(
              title: '删除规则',
              selected: true,
              onTap: () => onSelected(MenuDiscoverSource.delete),
              checkmark: CupertinoIcons.delete,
              iconColor: Colors.red,
              // textStyle: _themn.textStyle.copyWith(color: Colors.red),
            ),
          ];
        },
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildPage(BuildContext context) {
    return Consumer<EditSourceProvider>(
      builder: (context, provider, _) {
        List<Rule> rules = provider.rules
                ?.where((element) => element.enableDiscover == true)
                ?.toList() ??
            [];

        rules = provider.ruleContentType == -1
            ? rules
            : rules
                    ?.where((element) =>
                        element.contentType == provider.ruleContentType)
                    ?.toList() ??
                [];

        final isLoading = provider.isLoading;
        print("rules:${rules?.length},${provider.allRules.length}");
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: buildEndDrawer(context, provider),
          body: CupertinoPageScaffold(
            // backgroundColor: CupertinoColors.systemGroupedBackground,
            navigationBar: CupertinoNavigationBar(
              // transitionBetweenRoutes: false,
              border: null,
              middle: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 30,
                  child: CupertinoSearchTextField(
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColorDark
                            .withOpacity(0.06)),
                    focusNode: focusNode,
                    padding: EdgeInsets.zero,
                    onSubmitted: (value) =>
                        provider.getRuleListByNameDebounce(value, type: 2),
                    onChanged: (value) =>
                        provider.getRuleListByName(value, type: 2),
                    placeholder: "搜索发现,共${rules?.length ?? 0}条",
                    controller: _searchEdit,
                  ),
                ),
              ),
              trailing: focusNode.hasFocus
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text("取消"),
                      onPressed: () => focusNode.unfocus(),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoButton(
                          child: Icon(CupertinoIcons.add),
                          // child: Text('分组'),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            focusNode.unfocus();
                            showDialog(
                              context: context,
                              builder: (context) => UIAddRuleDialog(
                                  refresh: () => refreshData(provider)),
                            );
                          },
                        ),
                        CupertinoButton(
                          child: Icon(CupertinoIcons.slider_horizontal_3),
                          // child: Text('分组'),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _scaffoldKey.currentState.openEndDrawer();
                            focusNode.unfocus();
                          },
                        )
                      ],
                    ),
            ),
            child: SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  focusNode.unfocus();
                },
                onVerticalDragStart: (details) {
                  print("onVerticalDragEnd");
                  focusNode.unfocus();
                },
                onHorizontalDragStart: (details) {
                  print("onHorizontalDragEnd");
                  focusNode.unfocus();
                },
                child: Scrollbar(
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            SizedBox(height: 5),
                            _buildFilterView(context, provider),
                            if (isLoading && rules?.length == 0)
                              Center(
                                child: SizedBox(
                                  height: 200,
                                  child: CupertinoActivityIndicator(),
                                ),
                              ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      if (!isLoading && rules?.length != 0)
                        SliverList(
                          delegate: SliverChildListDelegate(
                            List.generate(rules?.length ?? 0, (index) {
                              return Container(
                                // margin: EdgeInsets.only(top: 20),
                                // padding: EdgeInsets.only(bottom: 30),
                                // height: 60,
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.zero,
                                // decoration: BoxDecoration(
                                //   border: Border(
                                //     top: index == 0
                                //         ? BorderSide(
                                //             color: Colors.grey,
                                //             width: 0.3,
                                //           )
                                //         : BorderSide.none,
                                //     bottom: BorderSide(
                                //       color: Colors.grey,
                                //       width: 0.2,
                                //     ),
                                //   ),
                                // ),
                                // height: 65,
                                child: _buildItems(
                                    context, provider, rules, index),
                              );
                              // return _buildItems(
                              //     context, provider, rules, index - 1);
                            })
                              ..add(SizedBox(
                                height: 50,
                              )),
                          ),
                        )
                      else if (!isLoading && provider.allRules.length == 0)
                        SliverList(
                          delegate: SliverChildListDelegate([
                            _buildEmptyHintView(provider),
                          ]),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterView(BuildContext context, EditSourceProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildFilterItemView(context, provider, -1),
          SizedBox(width: 8),
          _buildFilterItemView(context, provider, API.NOVEL),
          SizedBox(width: 8),
          _buildFilterItemView(context, provider, API.MANGA),
          SizedBox(width: 8),
          _buildFilterItemView(context, provider, API.AUDIO),
          SizedBox(width: 8),
          _buildFilterItemView(context, provider, API.VIDEO),
        ],
      ),
    );
  }

  Widget _buildFilterItemView(
      BuildContext context, EditSourceProvider provider, int contextType) {
    bool selected = provider.ruleContentType == contextType;
    return GestureDetector(
      onTap: () {
        provider.ruleContentType = contextType;

        // if (Utils.empty(_searchEdit?.text))
        //   provider.refreshData();
        // else
        //   provider.getRuleListByName(_searchEdit.text);
      },
      child: Material(
        color: selected
            ? Theme.of(context).primaryColor
            : Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            side: BorderSide(
                width: Global.borderSize,
                color: selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
          child: Text(
            contextType < 0 ? '全部' : API.getRuleContentTypeName(contextType),
            style: TextStyle(
              fontSize: 11,
              color: selected
                  ? Theme.of(context).cardColor
                  : Theme.of(context).textTheme.bodyLarge.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHintView(EditSourceProvider provider) {
    final _shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: BorderSide(
            color: Theme.of(context).dividerColor, width: Global.borderSize));
    final _txtStyle = TextStyle(
        fontSize: 13, color: Theme.of(context).hintColor, height: 1.3);
    return EmptyListMsgView(
        text: Column(
      children: [
        Text("没有可用的规则~~~"),
        SizedBox(height: 8),
        ButtonTheme(
          minWidth: 50,
          height: 20,
          shape: _shape,
          buttonColor: Colors.transparent,
          padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              TextButton(
                child: Text("导入规则", style: _txtStyle),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) =>
                      UIAddRuleDialog(refresh: () => refreshData(provider)),
                ),
              ),
              TextButton(
                child: Text("新建规则", style: _txtStyle),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EditRulePage(provider: provider))),
              ),
              TextButton(
                child: Text("规则管理", style: _txtStyle),
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EditSourcePage())),
              ),
            ],
          ),
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        isLargeScreen = true;
      } else {
        isLargeScreen = false;
      }

      return Row(children: <Widget>[
        Expanded(
          child: Material(
            child: _buildPage(context),
          ),
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

  refreshData(EditSourceProvider provider) {
    if (Utils.empty(_searchEdit?.text))
      provider.refreshData();
    else
      provider.getRuleListByName(_searchEdit.text, type: 2);
  }
}
