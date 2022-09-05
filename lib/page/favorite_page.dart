import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/page/history_pag_ios.dart';
import 'package:eso/page/setting/auto_backup_page.dart';
import 'package:eso/profile.dart';
import 'package:eso/page/setting/about_page.dart';
import 'package:eso/ui/widgets/form_section.dart';
import 'package:eso/ui/widgets/size_bar.dart';
import 'package:eso/utils.dart';
import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart' hide CupertinoFormSection;
import 'package:flutter/material.dart';
import 'package:eso/ui/round_indicator.dart';
import 'package:eso/page/favorite_list_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:left_scroll_actions/cupertinoLeftScroll.dart';
// import 'package:left_scroll_actions/left_scroll_actions.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:win32/win32.dart';
import '../fonticons_icons.dart';
import '../global.dart';
import 'add_local_item_page.dart';
import 'history_page.dart';
import 'search_page.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            leading: Container(), middle: Text('Modal Page')),
        child: SafeArea(
          bottom: false,
          child: Text("弹出"),
        ),
      ),
    );
  }
}

class GroupManage extends StatefulWidget {
  const GroupManage({Key key}) : super(key: key);

  @override
  State<GroupManage> createState() => _GroupManageState();
}

class _GroupManageState extends State<GroupManage> {
  // Set<String> favoriteGroups = Set();
  // @override
  // void initState() {
  //   super.initState();
  //   favoriteGroups.add("测试1");
  //   favoriteGroups.add("测试2");
  //   favoriteGroups.add("测试3");
  //   print("initsssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");
  // }

  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<Profile>(context, listen: false);
    final Set<String> favoriteGroups = profile.favoriteGroup.split(',').toSet();
    favoriteGroups.removeWhere((element) => element.isEmpty);
    final currentGroup = profile.currentGroup;
    Future<bool> onRemoveGroup(String name) async {
      bool ret = await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('确定删除分组[${name}]'),
            content: Text("删除此分组后,此分组的收藏将一并删除,确定要删除嘛？"),
            actions: [
              CupertinoDialogAction(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              CupertinoDialogAction(
                child: Text('删除'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
      if (ret) {
        favoriteGroups.removeWhere((element) => element == name);
        print("favoriteGroups:${favoriteGroups.join(',')}");
        // 删除分组后移动到默认分组
        profile.currentGroup = '';
        profile.favoriteGroup = favoriteGroups.join(',');
        SearchItemManager.searchItem
            .removeWhere((element) => element.group == name);

        // SearchItemManager.searchItem.forEach((element) {
        //   if (element.group == name) {
        //     element.group = '';
        //   }
        // });

        await SearchItemManager.saveSearchItem();
      }

      return ret;
    }

    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          // transitionBetweenRoutes: false,
          automaticallyImplyLeading: false,
          middle: Text("分组管理"),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text("新增"),
            onPressed: () async {
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text('新建分组'),
                    content: CupertinoTextField(
                      autofocus: true,
                      controller: _textEditingController,
                      placeholder: "分组名",
                    ),
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
                          if (!favoriteGroups
                              .add(_textEditingController.text)) {
                            Utils.toast(
                                "添加失败,${_textEditingController.text}已存在");
                            return;
                          }
                          // 去除空值
                          favoriteGroups
                              .removeWhere((element) => element.isEmpty);
                          profile.favoriteGroup = favoriteGroups.join(',');

                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SlidableAutoCloseBehavior(
                      child: CupertinoFormSection(
                        headerPadding: EdgeInsets.zero,
                        header: Text("分组列表"),
                        children: [
                          InkWell(
                            onTap: () {
                              profile.currentGroup = '';
                            },
                            child: CupertinoFormRow(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              prefix: Text("默认"),
                              child: currentGroup.isEmpty
                                  ? Icon(CupertinoIcons.checkmark_alt)
                                  : Container(height: 24),
                            ),
                          ),
                          ...favoriteGroups.map(
                            (e) => InkWell(
                              onTap: () {
                                profile.currentGroup = e;
                              },
                              child: Slidable(
                                key: ValueKey("$e"),
                                groupTag: "GroupTag",
                                direction: Axis.horizontal,
                                endActionPane: ActionPane(
                                    dismissible: DismissiblePane(
                                      closeOnCancel: true,
                                      confirmDismiss: () async {
                                        return await onRemoveGroup(e);
                                      },
                                      onDismissed: () => null,
                                    ),
                                    motion: DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        flex: 3,
                                        autoClose: true,
                                        onPressed: (bContext) {
                                          Future(
                                            () async {
                                              if (mounted) {
                                                final _slidableController =
                                                    Slidable.of(bContext);
                                                if (await onRemoveGroup(e)) {
                                                  _slidableController
                                                      .dismiss(ResizeRequest(
                                                          Duration(
                                                              milliseconds:
                                                                  200),
                                                          (() => null)))
                                                      .whenComplete(() =>
                                                          setState(() => null));
                                                }
                                              }
                                            },
                                          );
                                        },
                                        backgroundColor: Color(0xFFFE4A49),
                                        foregroundColor: Colors.white,
                                        label: '删除',
                                      ),
                                    ]),
                                child: CupertinoFormRow(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  prefix: Text(e),
                                  child: currentGroup == e
                                      ? Icon(CupertinoIcons.checkmark_alt)
                                      : Container(height: 24),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteLayout extends StatefulWidget {
  const FavoriteLayout({Key key}) : super(key: key);

  @override
  State<FavoriteLayout> createState() => _FavoriteLayoutState();
}

class _FavoriteLayoutState extends State<FavoriteLayout> {
  FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<Profile>(context, listen: false);

    final listMode = {
      0: '列表模式',
      1: '大图模式',
      2: '网格二列',
      3: '网格三列',
      4: '网格四列',
    };

    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          // transitionBetweenRoutes: false,
          middle: Text("列表布局"),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CupertinoFormSection.insetGrouped(
                headerPadding: EdgeInsets.zero,
                header: Text("列表布局,缩放系数只对网格模式生效"),
                children: [
                  CupertinoFormRow(
                    prefix: Text("缩放系数"),
                    child: SizedBox(
                      width: 100,
                      child: CupertinoTextField(
                        maxLines: 1,
                        onChanged: (value) =>
                            profile.listAspectRatio = double.tryParse(value),
                        focusNode: focusNode,
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: "${profile.listAspectRatio}",
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: "${profile.listAspectRatio}".length),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(
                    listMode.length,
                    (index) => InkWell(
                      onTap: () {
                        profile.listMode = index;
                        focusNode.unfocus();
                      },
                      child: CupertinoFormRow(
                        prefix: Text(listMode[index]),
                        child: profile.listMode == index
                            ? Icon(CupertinoIcons.check_mark)
                            : Container(),
                      ),
                    ),
                  ).toList()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoritePageWithIOS extends StatefulWidget {
  final void Function(Widget, void Function()) invokeTap;

  const FavoritePageWithIOS({this.invokeTap, Key key}) : super(key: key);

  @override
  State<FavoritePageWithIOS> createState() => _FavoritePageWithIOSState();
}

class _FavoritePageWithIOSState extends State<FavoritePageWithIOS> {
  static const tabs = [
    ["文字", API.NOVEL],
    ["图片", API.MANGA],
    ["音频", API.AUDIO],
    ["视频", API.VIDEO],
  ];

  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    final profile = Profile();
    if (Global.needShowAbout) {
      Global.needShowAbout = false;
      if (profile.version != profile.lastestVersion) {
        Future.delayed(Duration(milliseconds: 10),
            () => AboutPage.showAbout(context, true));
      }
      AutoBackupPage.backup(true);
      AutoBackupPage.shareRule(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        length: tabs.length,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            transitionBetweenRoutes: false,
            border: null,
            middle: SizedBar(
              height: 30,
              child: TabBar(
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor:
                    Theme.of(context).textTheme.bodyLarge.color,
                indicator: RoundTabIndicator(
                    insets: EdgeInsets.only(left: 5, right: 5),
                    borderSide: BorderSide(
                        width: 3.0, color: Theme.of(context).primaryColor)),
                tabs: tabs
                    .map((tab) => Container(
                        height: 30,
                        alignment: Alignment.center,
                        child: Text(
                          tab[0],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: Profile.staticFontFamily),
                        )))
                    .toList(),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        CupertinoPageRoute(builder: (context) => SearchPage()));
                  },
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.search,
                    size: 20,
                    // color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                PullDownButton(
                  position: PullDownMenuPosition.under,
                  widthConfiguration: PullDownMenuWidthConfiguration(160),
                  buttonBuilder: (BuildContext context, showMenu) =>
                      CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: showMenu,
                    child: const Icon(
                      CupertinoIcons.ellipsis,
                      // color: Colors.black,
                      size: 20,
                    ),
                  ),
                  itemBuilder: (context) {
                    final onSelected = (int type) {
                      switch (type) {
                        case 0:
                          Navigator.of(context, rootNavigator: true)
                              .push(CupertinoPageRoute<AddLocalItemPage>(
                            builder: (BuildContext context) =>
                                AddLocalItemPage(),
                          ));
                          break;
                        case 1:
                          setState(() {
                            _editMode = true;
                          });

                          break;

                        default:
                      }
                    };
                    return [
                      SelectablePullDownMenuItem(
                        title: '本地导入',
                        selected: true,
                        onTap: () => onSelected(0),
                        checkmark: CupertinoIcons.folder,
                      ),
                      // const PullDownMenuDivider(),
                      // SelectablePullDownMenuItem(
                      //   enabled: false,
                      //   title: '更新目录',
                      //   selected: true,
                      //   onTap: () => onSelected(1),
                      //   checkmark: CupertinoIcons.refresh,
                      // ),
                      const PullDownMenuDivider(),
                      SelectablePullDownMenuItem(
                        enabled: false,
                        title: '批量管理',
                        selected: true,
                        onTap: () => onSelected(1),
                        checkmark: CupertinoIcons.text_badge_checkmark,
                      ),
                      const PullDownMenuDivider(),
                      SelectablePullDownMenuItem(
                        enabled: true,
                        title: '列表布局',
                        selected: true,
                        onTap: () => showCupertinoModalBottomSheet(
                          expand: true,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => FavoriteLayout(),
                        ),
                        checkmark: CupertinoIcons.rectangle_grid_3x2,
                      ),
                      const PullDownMenuDivider(),
                      SelectablePullDownMenuItem(
                        enabled: true,
                        title: '分组管理',
                        selected: true,
                        onTap: () => showCupertinoModalBottomSheet(
                          expand: true,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => GroupManage(),
                        ),
                        checkmark: CupertinoIcons.square_stack_3d_up,
                      ),
                      const PullDownMenuDivider(),
                    ];
                  },
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: TabBarView(
              children: tabs
                  .map((tab) => FavoriteListPage(
                      type: tab[1],
                      invokeTap: widget.invokeTap,
                      editMode: _editMode))
                  .toList(),
            ),
            // child: CustomScrollView(
            //   slivers: [
            //     SliverList(
            //       delegate: SliverChildListDelegate(
            //         [],
            //       ),
            //     )
            //   ],
            // ),
          ),
        ),
      ),
    );
  }
}

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  var isLargeScreen = false;
  Widget detailPage;

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
          child: FavoritePageWithIOS(
              invokeTap: (Widget detailPage, void Function() callback) {
            if (isLargeScreen) {
              this.detailPage = detailPage;
              setState(() {});
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => detailPage,
                  )).whenComplete(() => callback());
            }
          }),
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
}
