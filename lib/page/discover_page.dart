import 'package:eso/api/api_form_rule.dart';
import 'package:eso/page/discover_search_page.dart';
import 'package:toast/toast.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/page/langding_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  Widget _page;
  EditSourceProvider __provider;

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
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Theme.of(context).canvasColor,
            brightness: Theme.of(context).brightness,
            title: Text(
              "发现",
              style:
                  TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                onPressed: () => Toast.show("发现设置", context),
              ),
            ],
          ),
          body: Consumer<EditSourceProvider>(
            builder: (context, EditSourceProvider provider, _) {
              if (__provider == null) {
                __provider = provider;
              }
              if (provider.isLoading) {
                return LandingPage();
              }
              return ListView.builder(
                itemCount: provider.rules.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return _buildItem(provider, index);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildItem(EditSourceProvider provider, int index) {
    final rule = provider.rules[index];
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DiscoverSearchPage(
                originTag: rule.id,
                origin: rule.name,
                discoverMap: APIFromRUle(rule).discoverMap(),
              ))),
      child: ListTile(
        title: Text('${rule.name}'),
        subtitle: Text(
          '${rule.host}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
//    return Slidable(
//      actionPane: SlidableDrawerActionPane(),
//      actionExtentRatio: 0.25,
//      child: InkWell(
//        onTap: () {
//          Toast.show(rule.name, context);
//        },
//        child: CheckboxListTile(
//          value: rule.enableSearch,
//          activeColor: Theme.of(context).primaryColor,
//          title: Text('${rule.name}'),
//          subtitle: Text(
//            '${rule.host}',
//            maxLines: 1,
//            overflow: TextOverflow.ellipsis,
//          ),
//          onChanged: (value) => provider.toggleEnableSearch(rule),
//        ),
//        onLongPress: () => Navigator.of(context).push(MaterialPageRoute(
//            builder: (context) => DiscoverSearchPage(
//              originTag: rule.id,
//              origin: rule.name,
//              discoverMap: APIFromRUle(rule).discoverMap(),
//            ))),
//      ),
//      actions: [
//        IconSlideAction(
//          caption: '置顶',
//          color: Colors.blueGrey,
//          icon: Icons.vertical_align_top,
//          onTap: () => provider.setSortMax(rule),
//        ),
//      ],
//      secondaryActions: <Widget>[
//        IconSlideAction(
//          caption: '编辑',
//          color: Colors.black45,
//          icon: Icons.create,
//          onTap: () => Navigator.of(context)
//              .push(MaterialPageRoute(
//              builder: (context) => EditRulePage(rule: rule)))
//              .then((value) => provider.refreshData()),
//        ),
//        IconSlideAction(
//          caption: '删除',
//          color: Colors.red,
//          icon: Icons.delete,
//          onTap: () => provider.deleteRule(rule),
//        ),
//      ],
//    );
  }
}
