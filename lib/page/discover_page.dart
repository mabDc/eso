import 'dart:ui';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_from_rule.dart';
import 'package:eso/page/discover_search_page.dart';
import 'package:eso/page/source/edit_source_page.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/ui/ui_text_field.dart';
import 'package:eso/ui/widgets/empty_list_msg_view.dart';
import 'package:eso/ui/widgets/keyboard_dismiss_behavior_view.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import '../fonticons_icons.dart';
import '../global.dart';
import '../ui/ui_add_rule_dialog.dart';
import 'source/edit_rule_page.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  Widget _page;
  EditSourceProvider __provider;
  TextEditingController _searchEdit = TextEditingController();

  static int _lastContextType = -1;

  @override
  void dispose() {
    __provider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_page == null) {
      _page = _buildPage();
    }
    return _page;
  }

  Widget _buildPage() {
    return ChangeNotifierProvider.value(
      value: EditSourceProvider(type: 2),
      builder: (BuildContext context, _) {
        final provider = Provider.of<EditSourceProvider>(context, listen: false);
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            titleSpacing: NavigationToolbar.kMiddleSpacing,
            title: SearchTextField(
              controller: _searchEdit,
              hintText: "搜索发现站点(共${provider.rules?.length ?? 0}条)",
              onSubmitted: (value) => __provider.getRuleListByName(value),
              onChanged: (value) => __provider.getRuleListByNameDebounce(value),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                tooltip: '添加规则',
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) =>
                      UIAddRuleDialog(refresh: () => refreshData(provider)),
                ),
              ),
              IconButton(
                icon: Icon(OMIcons.settingsEthernet),
                tooltip: '新建空白规则',
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => EditRulePage()))
                    .whenComplete(() => refreshData(provider)),
              ),
              IconButton(
                icon: Icon(FIcons.edit),
                tooltip: '规则管理',
                onPressed: () => Utils.startPageWait(context, EditSourcePage())
                    .whenComplete(() => refreshData(provider)),
              ),
            ],
          ),
          body: Consumer<EditSourceProvider>(
            builder: (context, EditSourceProvider provider, _) {
              if (__provider == null) {
                __provider = provider;
                provider.ruleContentType = _lastContextType;
              }
              if (provider.isLoading) {
                return Stack(
                  children: [
                    LandingPage(),
                    _buildFilterView(context, provider),
                  ],
                );
              }
              final _listView = ListView.builder(
                itemCount: provider.rules.length + 1,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) return _buildFilterView(context, provider);
                  return _buildItem(provider, index - 1);
                },
              );
              return KeyboardDismissBehaviorView(
                child: provider.rules.length == 0
                    ? Stack(
                        children: [
                          _listView,
                          _buildEmptyHintView(provider),
                        ],
                      )
                    : _listView,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterView(BuildContext context, EditSourceProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(12),
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
        _lastContextType = contextType;
        if (Utils.empty(_searchEdit?.text))
          provider.refreshData();
        else
          provider.getRuleListByName(_searchEdit.text);
      },
      child: Material(
        color: selected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
                  : Theme.of(context).textTheme.bodyText1.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(EditSourceProvider provider, int index) {
    final rule = provider.rules[index];
    Widget _child = ListTile(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FutureBuilder<List<DiscoverMap>>(
                future: APIFromRUle(rule).discoverMap(),
                initialData: null,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Text("error: ${snapshot.error}"),
                    );
                  }
                  if (!snapshot.hasData) {
                    return LandingPage();
                  }
                  return DiscoverSearchPage(
                    rule: rule,
                    originTag: rule.id,
                    origin: rule.name,
                    discoverMap: snapshot.data,
                  );
                },
              ))),
      onLongPress: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => EditRulePage(rule: rule)))
          .whenComplete(() => refreshData(provider)),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Flexible(
            child: Text(
              "${rule.name}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                textBaseline: TextBaseline.alphabetic,
                fontSize: 14,
                height: 1,
              ),
            ),
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
                height: 1.4,
                color: Colors.white,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        rule.author == '' ? '${rule.host}' : '@${rule.author}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    if (index < provider.rules.length - 1) return _child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_child, SizedBox(height: 30)],
    );
  }

  Widget _buildEmptyHintView(EditSourceProvider provider) {
    final _shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side:
            BorderSide(color: Theme.of(context).dividerColor, width: Global.borderSize));
    final _txtStyle =
        TextStyle(fontSize: 13, color: Theme.of(context).hintColor, height: 1.3);
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
              FlatButton(
                child: Text("导入规则", style: _txtStyle),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) =>
                      UIAddRuleDialog(refresh: () => refreshData(provider)),
                ),
              ),
              FlatButton(
                child: Text("新建规则", style: _txtStyle),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => EditRulePage())),
              ),
              FlatButton(
                child: Text("规则管理", style: _txtStyle),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => EditSourcePage())),
              ),
            ],
          ),
        )
      ],
    ));
  }

  refreshData(EditSourceProvider provider) {
    if (Utils.empty(_searchEdit?.text))
      provider.refreshData();
    else
      provider.getRuleListByName(_searchEdit.text);
  }
}
