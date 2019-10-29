import 'dart:math';

import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/discover_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../api/api_manager.dart';
import '../ui/ui_discover_item.dart';
import 'DiscoverSearchPage.dart';
import 'chapter_page.dart';
import 'langding_page.dart';

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
            height: 4,
          );
        },
        padding: EdgeInsets.all(6),
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
                        originTag: allAPI[index].originTag,
                        origin: allAPI[index].origin,
                        discoverMap: allAPI[index].discoverMap(),
                      ))),
            ),
          );
        },
      ),
    );
  }
}


