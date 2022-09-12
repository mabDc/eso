import 'package:eso/api/api.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:eso/ui/widgets/icon_text.dart';
import 'package:flutter/material.dart';
import '../database/search_item.dart';
import '../fonticons_icons.dart';
import '../utils.dart';

class UiSearchItem extends StatelessWidget {
  final SearchItem item;
  final bool showType;

  const UiSearchItem({
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

  static const _padding = const EdgeInsets.only(right: 4, bottom: 1);

  @override
  Widget build(BuildContext context) {
    final _txtStyle = TextStyle(
        color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
        fontFamily: ESOTheme.staticFontFamily,
        fontSize: 13);
    return Container(
      constraints: BoxConstraints(minHeight: 110, minWidth: double.infinity),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: DefaultTextStyle(
        style: TextStyle(
            fontFamily: ESOTheme.staticFontFamily,
            fontSize: 13,
            color: Theme.of(context).hintColor,
            height: 1.5),
        overflow: TextOverflow.ellipsis,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 8),
            SizedBox(
              width: 80,
              height: 104,
              child: UIImageItem(
                  cover: cover, hero: Utils.empty(cover) ? null : '$name.$cover.$id'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name?.trim() ?? '',
                          maxLines: 2,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: ESOTheme.staticFontFamily,
                              color: Theme.of(context).textTheme.bodyText1.color,
                              fontSize: 15),
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
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                  _buildLine1(context, _txtStyle),
                  Utils.empty(chapter?.trim())
                      ? SizedBox()
                      : IconText(
                          "${chapter.trim()}",
                          icon: Icon(FIcons.clock),
                          maxLines: 1,
                          padding: _padding,
                          style: _txtStyle,
                        ),
                  SizedBox(height: 5),
                  Utils.empty(description?.trim())
                      ? SizedBox()
                      : Text(
                          description.trim(),
                          maxLines: 2,
                          style: TextStyle(fontSize: 12),
                        ),
                ],
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLine1(BuildContext context, TextStyle style) {
    final _author = author?.trim();
    final _origin = origin?.trim();
    final _authorView = Utils.empty(_author)
        ? null
        : IconText(
            '$_author',
            icon: Icon(FIcons.user),
            maxLines: 1,
            padding: _padding,
            style: style,
          );
    final _originView = Utils.empty(_origin)
        ? null
        : IconText(
            '$_origin',
            icon: Icon(FIcons.compass),
            maxLines: 1,
            padding: _padding,
            style: style,
          );

    if (_authorView == null && _originView == null) return SizedBox();
    if (_authorView == null || _originView == null)
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: double.infinity),
        child: _authorView ?? _originView,
      );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.45),
          child: _authorView,
        ),
        SizedBox(width: 8),
        Expanded(
          child: _originView,
        ),
      ],
    );
  }
}
