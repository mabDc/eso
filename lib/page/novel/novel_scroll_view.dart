import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/page/novel/novel_one_page_view.dart';
import 'package:eso/ui/ui_dash.dart';
import 'package:eso/ui/widgets/icon_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 滚动模式
class NovelScrollView extends StatelessWidget {
  final NovelPageProvider provider;
  final Profile profile;
  final SearchItem searchItem;

  const NovelScrollView({Key key, this.profile, this.provider, this.searchItem})
      : super(key: key);

  static Color _fontColor, _fontColor70;

  get _txtStyle => TextStyle(color: _fontColor70);
  get _txtNormal => TextStyle(color: _fontColor);

  @override
  Widget build(BuildContext context) {
    _fontColor = Color(profile.novelFontColor);
    _fontColor70 = _fontColor.withOpacity(0.7);

    final RefreshController refreshController = RefreshController();
    return NotificationListener(
      onNotification: (t) {
        if (t is ScrollEndNotification) {
          provider.refreshProgress();
        }
        return false;
      },
      child: _buildContent(context, refreshController),
    );
  }

  Widget _buildContent(
      BuildContext context, RefreshController refreshController) {
    final spans = provider.didUpdateReadSetting(profile)
        ? provider.updateSpansFlat(NovelPageProvider.buildSpans(
            profile, provider.searchItem, provider.paragraphs))
        : provider.spansFlat;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: <Widget>[
          Expanded(
            child: RefreshConfiguration(
              enableBallisticLoad: false,
              child: SmartRefresher(
                  header: CustomHeader(builder: _buildHeader),
                  footer: CustomFooter(builder: _buildFooter),
                  controller: refreshController,
                  enablePullUp: true,
                  child: ListView(
                    controller: provider.controller,
                    padding: EdgeInsets.only(
                      left: profile.novelLeftPadding,
                      top: profile.novelTopPadding,
                      right: profile.novelLeftPadding - 5,
                    ),
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      provider.useSelectableText
                          ? SelectableText.rich(
                              TextSpan(
                                style: _txtNormal,
                                children: spans,
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                children: spans,
                                style: _txtNormal,
                              ),
                            ),
                      _buildEndText(),
                    ],
                  ),
                  onRefresh: () async {
                    await provider.loadChapterHideLoading(true);
                    refreshController.refreshCompleted();
                  },
                  onLoading: () async {
                    await provider.loadChapterHideLoading(false);
                    refreshController.loadComplete();
                  }),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          NovelOnePageView.bottomLine(_fontColor),
          _buildFooterStatus(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RefreshStatus mode) {
    Widget body;
    if (mode == RefreshStatus.idle) {
      body = IconText(
        "下拉加载上一章",
        icon: Icon(Icons.arrow_downward),
        padding: EdgeInsets.only(right: 4),
        style: _txtStyle,
      );
    } else if (mode == RefreshStatus.refreshing) {
      body = CupertinoActivityIndicator();
    } else if (mode == RefreshStatus.failed) {
      body = Text(
        "加载失败!请重试!",
        textAlign: TextAlign.justify,
        style: _txtStyle,
      );
    } else if (mode == RefreshStatus.canRefresh) {
      body = IconText(
        "松手加载上一章",
        icon: Icon(Icons.arrow_upward),
        padding: EdgeInsets.only(right: 4),
        style: _txtStyle,
      );
    } else {
      body = Text(
        "没有更多数据了",
        style: _txtStyle,
      );
    }
    return Container(
      height: 60.0,
      alignment: Alignment.center,
      child: body,
    );
  }

  Widget _buildFooter(BuildContext context, LoadStatus mode) {
    Widget body;
    if (mode == LoadStatus.idle) {
      body = IconText(
        "上拉加载下一章",
        icon: Icon(Icons.arrow_upward),
        padding: EdgeInsets.only(right: 4),
        style: _txtStyle,
      );
    } else if (mode == LoadStatus.loading) {
      body = CupertinoActivityIndicator();
    } else if (mode == LoadStatus.failed) {
      body = Text(
        "加载失败!请重试!",
        style: _txtStyle,
      );
    } else if (mode == LoadStatus.canLoading) {
      body = IconText(
        "松手加载下一章",
        icon: Icon(Icons.arrow_downward),
        padding: EdgeInsets.only(right: 4),
        style: _txtStyle,
      );
    } else {
      body = Text(
        "没有更多数据了",
        style: _txtStyle,
      );
    }
    return Container(
      height: 60.0,
      alignment: Alignment.center,
      child: body,
    );
  }

  Widget _buildEndText() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 50, 24, 16),
      child: Text(
        "当前章节已结束\n${provider.searchItem.durChapter}",
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 2,
          color: _fontColor70,
        ),
      ),
    );
  }

  Widget _buildFooterStatus() {
    final _txt = Text(
      '${provider.progress}%',
      textAlign: TextAlign.right,
      style: _txtNormal,
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: profile.novelLeftPadding),
      height: 24,
      child: DefaultTextStyle(
        style: TextStyle(color: _fontColor70, fontSize: 12),
        child: Row(
          children: provider.useSelectableText ? [
            FlatButton(
              child: IconText(
                '退出复制模式',
                icon: Icon(Icons.clear),
                iconSize: 16,
              ),
              onPressed: () => provider.useSelectableText = false,
            ),
            Expanded(child: SizedBox()),
            _txt,
          ] : [
            Expanded(
              child: Text(
                '${searchItem.durChapter}',
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
  }
}
