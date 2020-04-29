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
        title: Text('发现'),
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return Container(height: 4);
            },
            itemCount: allAPI.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Card(
                  child: ListTile(
                    title: Text("test_rule"),
                    trailing: Switch(
                      activeColor: Theme.of(context).primaryColor,
                      value: true,
                      onChanged: (enable) {},
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DiscoverSearchPage(
                              originTag: "test_rule",
                              origin: "test_rule",
                              discoverMap: <DiscoverMap>[],
                            ))),
                  ),
                );
              }
              index = index - 1;
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
