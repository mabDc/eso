import 'package:eso/database/search_item.dart';
import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/profile.dart';
import 'package:eso/page/novel/novel_drag_view.dart';
import 'package:eso/page/novel/novel_one_page_view.dart';
import 'package:flutter/material.dart';

/// 点击翻页模式
class NovelNoneView extends StatelessWidget {
  final NovelPageProvider provider;
  final Profile profile;
  final SearchItem searchItem;

  const NovelNoneView({Key key, this.profile, this.provider, this.searchItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _spans = provider.didUpdateReadSetting(profile)
        ? provider.updateSpans(NovelPageProvider.buildSpans(context, profile, provider.searchItem, provider.paragraphs))
        : provider.spans;

    return NovelDragView(
      provider: provider,
      profile: profile,
      child: NovelOnePageView(
        provider: provider,
        profile: profile,
        spans: _spans[provider.currentPage - 1],
        fontColor: Color(profile.novelFontColor),
        pageInfo: '${provider.currentPage}/${_spans.length}',
        chapterName: searchItem.durChapter,
      ),
    );
  }

}