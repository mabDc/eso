import 'package:eso/model/history_manager.dart';
import 'package:eso/model/search_page_delegate.dart';
import 'package:provider/provider.dart';

import '../api/api_manager.dart';
import 'package:flutter/material.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allAPI = APIManager.allAPI;
    return Scaffold(
      appBar: AppBar(
        title: Text('发现'),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 6,
          );
        },
        itemCount: allAPI.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(allAPI[index].origin),
              trailing: Switch(
                activeColor: Theme.of(context).primaryColor,
                value: true,
                onChanged: (enable) {},
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      DiscoverItemPage(allAPI[index].origin))),
            ),
          );
        },
      ),
    );
  }
}

class DiscoverItemPage extends StatelessWidget {
  final String name;

  const DiscoverItemPage(this.name, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: SearchPageDelegate(
                historyManager: Provider.of<HistoryManager>(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
