import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/ui/ui_dash.dart';
import 'package:eso/ui/widgets/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../global.dart';

/// 显示指定页
class NovelOnePageView extends StatelessWidget {
  final NovelPageProvider provider;
  final Profile profile;
  final List<InlineSpan> spans;
  final Color fontColor;
  final String chapterName;
  final String pageInfo;

  /// 底部分隔线
  static Widget bottomLine (Color fontColor) => UIDash(
    height: Global.lineSize,
    dashWidth: 2,
    color: fontColor.withOpacity(0.5),
  );

  /// 底部状态栏
  static Widget buildFooterStatus({String chapter, String msg, Color fontColor, double padding, NovelPageProvider provider}) {
    final _txt = Text(
      msg,
      textAlign: TextAlign.right,
      style: TextStyle(color: fontColor, fontFamily: Profile.fontFamily),
    );
    return Builder(
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: padding),
          height: 24,
          child: DefaultTextStyle(
            style: TextStyle(color: fontColor, fontSize: 12,
                fontFamily: Profile.fontFamily),
            child: Row(
              children: (Provider.of<NovelPageProvider>(context, listen: true)?.useSelectableText ?? false) ? [
                ButtonTheme(
                  padding: EdgeInsets.zero,
                  minWidth: 10,
                  child: FlatButton(
                    child: IconText(
                      '退出复制模式',
                      style: TextStyle(color: fontColor,
                          fontFamily: Profile.fontFamily),
                      icon: Icon(Icons.clear),
                      iconSize: 16,
                    ),
                    onPressed: () => provider.useSelectableText = false,
                  ),
                ),
                Expanded(child: SizedBox()),
                _txt,
              ] : [
                Expanded(
                  child: Text(
                    '$chapter',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                _txt,
              ],
            ),
          ),
        );
      },
    );
  }

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
              child: RichText(text: TextSpan(children: spans,
                  style: TextStyle(color: fontColor,
                      fontFamily: Profile.fontFamily))),
            ),
          ),
          SizedBox(height: 4),
          bottomLine(fontColor),
          buildFooterStatus(
              chapter: chapterName,
              msg: pageInfo,
              padding: profile.novelLeftPadding,
              fontColor: fontColor,
              provider: provider)
        ],
      ),
    );
  }
}