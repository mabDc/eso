import 'package:eso/api/api.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:flutter/material.dart';
import '../database/search_item.dart';
import '../global.dart';
import '../utils.dart';

class UiSearch2Item extends StatelessWidget {
  final SearchItem item;
  final bool showType;

  const UiSearch2Item({
    @required this.item,
    this.showType = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _UiSearchItem(
      id: item.id,
      origin: showType ? item.origin : "",
      cover: item.cover,
      name: item.name,
      author: item.author,
      chapter: item.chapter,
      description: item.description,
      contentTypeName: showType ? API.getRuleContentTypeName(item.ruleContentType) : "",
    );
  }
}

class _UiSearchItem extends StatelessWidget {
  final int id;
  final String origin;
  final String cover;
  final String name;
  final String author;
  final String chapter;
  final String description;
  final String contentTypeName;

  const _UiSearchItem({
    this.id,
    this.origin,
    this.cover,
    this.name,
    this.author,
    this.chapter,
    this.description,
    this.contentTypeName,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _author = author?.trim();
    final _chapter = chapter?.trim();
    final _description = description?.trim();
    final _origin = origin?.trim();
    final _txtColor = Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7);
    final _textStyle = TextStyle(
        color: _txtColor, fontFamily: ESOTheme.staticFontFamily, height: 1.0, fontSize: 13);
    final _chapterText =
        Utils.empty(_chapter) ? null : Text(_chapter, maxLines: 1, style: _textStyle);
    final _originText =
        Utils.empty(_origin) ? null : Text(_origin, maxLines: 1, style: _textStyle);
    final _authorText = Utils.empty(_author)
        ? null
        : Text(_author,
            maxLines: 1,
            // icon: Icon(FIcons.user),
            // iconSize: 13,
            // padding: const EdgeInsets.only(right: 4),
            style: _textStyle,
            textAlign: _chapterText == null && _originText == null
                ? TextAlign.start
                : TextAlign.end);

    final children = <Widget>[
      SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        SizedBox(width: 8),
        Expanded(
          child: Text(
            name?.trim() ?? '',
            maxLines: 2,
            style: TextStyle(
                fontFamily: ESOTheme.staticFontFamily,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyText1.color,
                fontSize: 16),
          ),
        ),
        contentTypeName != null && contentTypeName.isNotEmpty
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(left: 6),
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                alignment: Alignment.centerLeft,
                child: Text(
                  contentTypeName,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Colors.white,
                    fontFamily: ESOTheme.staticFontFamily,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              )
            : SizedBox(),
        SizedBox(width: 8),
      ]),
      SizedBox(
        width: double.infinity,
        height: 185,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 6),
          child: UIImageItem(
              cover: cover, hero: Utils.empty(cover) ? null : '$name.$cover.$id'),
        ),
      ),
    ];

    if (!Utils.empty(_description)) {
      children.addAll([
        SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Text(_description, maxLines: 3),
        )
      ]);
    }

    if (_chapterText != null || _authorText != null || _originText != null) {
      children.addAll([
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 8),
            _chapterText == null ? SizedBox() : Expanded(child: _chapterText),
            _originText == null ? SizedBox() : _originText,
            _authorText == null
                ? SizedBox()
                : Expanded(
                    child: _authorText,
                  ),
            SizedBox(width: 8),
          ],
        ),
      ]);
    }

    children.addAll([
      SizedBox(height: 8),
      Divider(height: Global.lineSize),
    ]);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 105, minWidth: double.infinity),
      child: DefaultTextStyle(
        style: TextStyle(
            fontFamily: ESOTheme.staticFontFamily,
            fontSize: 12,
            color: Theme.of(context).hintColor,
            height: 1.5),
        overflow: TextOverflow.ellipsis,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
