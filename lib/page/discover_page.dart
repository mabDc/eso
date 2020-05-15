import 'package:eso/api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../api/api_manager.dart';
import 'discover_search_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allAPI = APIManager.allAPI;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        brightness: Theme.of(context).brightness,
        title: Text(
          '发现',
          style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
        ),
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return Container(height: 4);
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
                      builder: (context) => DiscoverSearchPage(
                            originTag: allAPI[index]?.originTag,
                            origin: allAPI[index].origin,
                            discoverMap: allAPI[index].discoverMap(),
                          ))),
                ),
              );
            },
          )),
    );
  }
}
