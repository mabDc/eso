import 'package:flutter/material.dart';

import '../database/fake_data.dart';
import '../global.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:ListView.builder(
        padding: EdgeInsets.only(top: 0),
        itemBuilder: (context, index){
          return FadeInImage.assetNetwork(
            placeholder: Global.waitingPath,
            image: FakeData.picUrl,
          );
        },
      ),
    );
  }
}
