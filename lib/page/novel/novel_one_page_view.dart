import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/ui/ui_dash.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';

/// 显示指定页
class NovelOnePageView extends StatelessWidget {
  final NovelPageProvider provider;
  final Profile profile;
  final List<TextSpan> spans;
  final Color fontColor;
  final String chapterName;
  final String pageInfo;

  static Widget bottomLine (Color fontColor) => UIDash(
    height: Global.lineSize,
    dashWidth: 2,
    color: fontColor.withOpacity(0.5),
  );

  const NovelOnePageView({
    Key key,
    this.provider,
    this.profile,
    this.spans,
    this.fontColor,
    this.chapterName,
    this.pageInfo,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(profile.novelBackgroundColor),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: profile.novelLeftPadding,
                top: profile.novelTopPadding,
                right: profile.novelLeftPadding - 5,
              ),
              width: double.infinity,
              child: RichText(text: TextSpan(children: spans, style: TextStyle(color: fontColor))),
            ),
          ),
          SizedBox(height: 4),
          bottomLine(fontColor),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 + profile.novelLeftPadding),
            height: 26,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    '$chapterName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fontColor),
                  ),
                ),
                Text(
                  '$pageInfo',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: fontColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}