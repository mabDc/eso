import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/ui/widgets/draggable_scrollbar_sliver.dart';
import 'package:flutter/material.dart';

import 'ui_dash.dart';

/// 章节列表
class UIChapterSelect extends StatefulWidget {
  final SearchItem searchItem;
  final Function(int index) loadChapter;
  final Color color;
  final Color fontColor;
  final double heightScale;
  final BorderSide border;
  const UIChapterSelect({
    this.loadChapter,
    this.searchItem,
    this.color,
    this.fontColor,
    this.heightScale = 0.55,
    this.border,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UIChapterSelectState();
}

class _UIChapterSelectState extends State<UIChapterSelect> {
  ScrollController _controller;
  final itemHeight = 46.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = MediaQuery.of(context);
    final size = _theme.size;
    final screenHeight = size.height - _theme.padding.top - _theme.padding.bottom - 50;
    final _height = widget.searchItem.chapters.length * itemHeight;
    final durHeight = widget.searchItem.durChapterIndex * itemHeight;
    double offset;
    if (_height <= screenHeight) {
      offset = 1.0;
    } else if ((_height - durHeight) < screenHeight) {
      offset = _height - screenHeight - 1;
    } else {
      offset = durHeight;
    }

    _controller = ScrollController(initialScrollOffset: offset);

    final primaryColor = Theme.of(context).primaryColor;
    final _divider = UIDash(
        height: Global.lineSize, dashWidth: 4, color: Theme.of(context).dividerColor);
    final _count = widget.searchItem.chapters.length;

    final _listView = ListView.builder(
      itemExtent: itemHeight,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      controller: _controller,
      itemCount: _count,
      itemBuilder: (_, index) {
        return Container(
          height: itemHeight,
          child: _buildChapter(index, primaryColor, _divider),
        );
      },
    );

    return Center(
      child: Card(
        elevation: 8,
        color: widget.color ?? Theme.of(context).canvasColor.withOpacity(0.95),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: widget.border ?? BorderSide.none),
        child: Container(
          height: size.height * widget.heightScale,
          width: size.width * 0.85,
          constraints: BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: Colors.transparent,
            child: DefaultTextStyle(
              style: TextStyle(
                  color: widget.fontColor ?? Theme.of(context).textTheme.bodyText1.color,
                  fontSize: 16,
                  fontFamily: ESOTheme.staticFontFamily),
              child: _count > 64
                  ? DraggableScrollbar.semicircle(
                      controller: _controller,
                      child: _listView,
                    )
                  : _listView,
            ),
          ),
        ),
      ),
    );
  }

  Column _buildChapter(int index, Color primaryColor, Widget _divider) {
    final _selected = widget.searchItem.durChapterIndex == index;
    final _txt = Text(
      '${widget.searchItem.chapters[index].name}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _selected ? TextStyle(fontWeight: FontWeight.bold) : null,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () => widget.loadChapter(index),
            child: _selected
                ? Row(
                    children: <Widget>[
                      SizedBox(width: 8),
                      Expanded(child: _txt),
                      Icon(Icons.done, color: primaryColor),
                      SizedBox(width: 8),
                    ],
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.centerLeft,
                    child: _txt,
                  ),
          ),
        ),
        _divider
      ],
    );
  }
}
