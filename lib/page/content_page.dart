import 'package:flutter/material.dart';

import '../api/fake_data.dart';
import '../global.dart';

class ContentPage extends StatelessWidget {
  final List imageList;

  const ContentPage({
    this.imageList,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageList == null) {
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
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: imageList.length,
        itemBuilder: (context, index) {
          return FadeInImage.assetNetwork(
            placeholder: Global.waitingPath,
            image: '${imageList[index]}',
          );
        },
      ),
    );
  }
}
