import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UIChapterLoding extends StatelessWidget {
  const UIChapterLoding({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).canvasColor,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 42,
            vertical: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(),
              SizedBox(height: 20),
              Text(
                "加载中...",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
