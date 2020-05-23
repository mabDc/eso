import 'dart:ui';

import 'package:eso/api/api_from_rule.dart';
import 'package:eso/page/discover_search_page.dart';
import 'package:eso/page/source/edit_source_page.dart';
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
                hintText:
                    "搜索发现站点(共${Provider.of<EditSourceProvider>(context).rules?.length ?? 0}条)",
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
              onSubmitted: (value) => __provider.getRuleListByName(value),
              onChanged: (value) => __provider.getRuleListByNameDebounce(value),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => EditSourcePage())),
              )
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
        title: Row(
          children: <Widget>[
            Text("${rule.name}"),
            Padding(
              padding: EdgeInsets.only(top:2, left: 5),
              child: Material(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                  child: Text('${rule.ruleTypeName}',
                      style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ),
            )
          ],
        ),
        subtitle: Text(
          '${rule.host}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
