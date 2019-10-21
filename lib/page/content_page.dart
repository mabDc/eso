import 'package:eso/api/mankezhan.dart';
import 'package:flutter/material.dart';

import '../database/fake_data.dart';
import '../global.dart';
import 'langding_page.dart';

class ContentPage extends StatelessWidget {
  final String comicId;
  final String chapterId;

  const ContentPage({
    this.comicId,
    this.chapterId,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (comicId == null || chapterId == null) {
      return Scaffold(
        body: ListView.builder(
          padding: EdgeInsets.only(top: 0),
          itemBuilder: (context, index) {
            return FadeInImage.assetNetwork(
              placeholder: Global.waitingPath,
              image: FakeData.picUrl,
            );
          },
        ),
      );
    }
    return FutureBuilder<List>(
      future: Mankezhan.content(comicId, chapterId),
      builder: (BuildContext context, AsyncSnapshot<List> data) {
        if (!data.hasData) {
          return LandingPage();
        }
        return Scaffold(
          body: ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: data.data.length,
            itemBuilder: (context, index) {
              return FadeInImage.assetNetwork(
                placeholder: Global.waitingPath,
                image: '${data.data[index]["image"]}!page-1200',
              );
            },
          ),
        );
      },
    );
  }
}
